import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/resolver.dart';
import 'package:mikan_flutter/internal/store.dart';

class _BaseInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final int timeout = 60 * 1000;
    options.baseUrl = MikanUrl.BASE_URL;
    options.connectTimeout = timeout;
    options.receiveTimeout = timeout;
    options.headers["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/86.0.4240.75 Safari/537.36 "
        "MikanFlutter/0.0.1";
    options.headers['client'] = "mikan_flutter";
    options.headers['os'] = Platform.operatingSystem;
    options.headers['osv'] = Platform.operatingSystemVersion;
    super.onRequest(options, handler);
  }
}

class MikanTransformer extends DefaultTransformer {
  @override
  Future transformResponse(
    RequestOptions options,
    ResponseBody response,
  ) async {
    final transformResponse = await super.transformResponse(options, response);
    final String? func = options.extra["$MikanFunc"];
    if (func.isNotBlank && transformResponse is String) {
      final Document document = parse(transformResponse);
      switch (func) {
        case MikanFunc.SEASON:
          return await Resolver.parseSeason(document);
        case MikanFunc.DAY:
          return await Resolver.parseDay(document);
        case MikanFunc.SEARCH:
          return await Resolver.parseSearch(document);
        case MikanFunc.USER:
          return await Resolver.parseUser(document);
        case MikanFunc.LIST:
          return await Resolver.parseList(document);
        case MikanFunc.INDEX:
          return await Resolver.parseIndex(document);
        case MikanFunc.SUBGROUP:
          return await Resolver.parseSubgroup(document);
        case MikanFunc.BANGUMI:
          return await Resolver.parseBangumi(document);
        case MikanFunc.BANGUMI_MORE:
          return await Resolver.parseBangumiMore(document);
        case MikanFunc.DETAILS:
          return await Resolver.parseRecordDetail(document);
        case MikanFunc.SUBSCRIBED_SEASON:
          return await Resolver.parseMySubscribed(document);
        case MikanFunc.REFRESH_LOGIN_TOKEN:
          return await Resolver.parseRefreshLoginToken(document);
        case MikanFunc.REFRESH_REGISTER_TOKEN:
          return await Resolver.parseRefreshRegisterToken(document);
      }
    }
    return transformResponse;
  }
}

class _Http extends DioForNative {
  _Http({
    String? cookiesDir,
    BaseOptions? options,
  }) : super(options) {
    // this.httpClientAdapter = Http2Adapter(ConnectionManager());
    // (this.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //     (client) {
    //   // config the http client
    //   client.findProxy = (url) {
    //     return HttpClient.findProxyFromEnvironment(url, environment: {
    //       "http_proxy": "http://192.168.101.6:8888",
    //       "https_proxy": "https://192.168.101.6:8888"
    //     });
    //   };
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) => true;
    //   // you can also create a HttpClient to dio
    //   // return HttpClient();
    // };
    this.interceptors
      ..add(_BaseInterceptor())
      ..add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          request: false,
          requestBody: false,
          responseBody: false,
          error: true,
          logPrint: (m) => m.debug(),
        ),
      )
      ..add(CookieManager(PersistCookieJar(storage: FileStorage(cookiesDir))));

    this.transformer = MikanTransformer();
  }
}

final Future<LoadBalancer> loadBalancer =
    LoadBalancer.create(1, IsolateRunner.spawn);

class _Fetcher {
  late final _Http _http;
  static _Fetcher? _fetcher;

  factory _Fetcher({
    String? cookiesDir,
  }) {
    if (_fetcher == null) {
      _fetcher = _Fetcher._(cookiesDir: cookiesDir);
    }
    return _fetcher!;
  }

  _Fetcher._({
    final String? cookiesDir,
  }) {
    _http = _Http(cookiesDir: cookiesDir);
  }

  static Future<Resp> _asyncInIsolate(final _Protocol proto) async {
    final ReceivePort receivePort = ReceivePort();
    final LoadBalancer lb = await loadBalancer;
    await lb.run(_parsingInIsolate, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    final ReceivePort resultPort = ReceivePort();
    proto._sendPort = resultPort.sendPort;
    sendPort.send(proto);
    return await resultPort.first;
  }

  static _parsingInIsolate(final SendPort sendPort) async {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((final proto) async {
      try {
        final _Http http = _Fetcher(cookiesDir: proto.cookiesDir)._http;
        Response resp;
        if (proto.method == _RequestMethod.GET) {
          resp = await http.get(
            proto.url,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.POST_FORM) {
          resp = await http.post(
            proto.url,
            data: FormData.fromMap(proto.data),
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.POST_JSON) {
          resp = await http.post(
            proto.url,
            data: proto.data,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else {
          return proto._sendPort
              .send(Resp(false, msg: "Not support request method."));
        }
        if (resp.statusCode == HttpStatus.ok) {
          if (proto.method == _RequestMethod.POST_FORM &&
              (resp.requestOptions.path == MikanUrl.LOGIN ||
                  resp.requestOptions.path == MikanUrl.REGISTER)) {
            proto._sendPort.send(Resp(
              false,
              msg: resp.requestOptions.path == MikanUrl.LOGIN
                  ? "登录失败，请稍后重试"
                  : "注册失败，请稍后重试",
            ));
          } else {
            proto._sendPort.send(Resp(true, data: resp.data));
          }
        } else {
          proto._sendPort.send(
            Resp(
              false,
              msg: "${resp.statusCode}: ${resp.statusMessage}",
            ),
          );
        }
      } catch (e) {
        if (e is DioError &&
            e.response?.statusCode == 302 &&
            proto.method == _RequestMethod.POST_FORM &&
            (e.requestOptions.path == MikanUrl.LOGIN ||
                e.requestOptions.path == MikanUrl.REGISTER)) {
          proto._sendPort.send(Resp(true));
        } else {
          "请求出错：$e".error();
          proto._sendPort.send(Resp(false, msg: e.toString()));
        }
      }
    });
  }
}

class Http {
  const Http._();

  static Future<Resp> get(
    final String url, {
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.GET,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postForm(
    final String url, {
    final data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.POST_FORM,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postJSON(
    final String url, {
    final data,
    final Map<String, dynamic>? queryParameters,
    final Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.POST_JSON,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: Store.cookiesPath,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }
}

enum _RequestMethod { POST_FORM, POST_JSON, GET }

class _Protocol {
  final String url;
  final _RequestMethod method;
  final data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;

  final String? cookiesDir;
  late SendPort _sendPort;

  _Protocol(
    this.url,
    this.method, {
    this.data,
    this.queryParameters,
    this.options,
    this.cookiesDir,
  });
}

class Resp {
  final dynamic data;
  final bool success;
  final String? msg;

  Resp(this.success, {this.msg, this.data});

  @override
  String toString() {
    return 'Resp{data: $data, success: $success, msg: $msg}';
  }
}
