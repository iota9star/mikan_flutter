import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart';
import 'package:isolate/isolate_runner.dart';
import 'package:isolate/load_balancer.dart';
import 'package:jiffy/jiffy.dart';

import 'consts.dart';
import 'extension.dart';
import 'hive.dart';
import 'log.dart';
import 'resolver.dart';

class _BaseInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    const timeout = Duration(seconds: 60);
    options.connectTimeout = timeout;
    options.receiveTimeout = timeout;
    options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/112.0.0.0 '
        'Safari/537.36 '
        'MikanFlutter/1.0.0';
    options.headers['client'] = 'MikanProject';
    options.headers['os'] = Platform.operatingSystem;
    options.headers['osv'] = Platform.operatingSystemVersion;
    super.onRequest(options, handler);
  }
}

class MikanTransformer extends SyncTransformer {
  @override
  Future transformResponse(
    RequestOptions options,
    ResponseBody response,
  ) async {
    final transformResponse = await super.transformResponse(options, response);
    if (transformResponse is String) {
      final String? func = options.extra['$MikanFunc'];
      if (func.isNotBlank) {
        final document = parse(transformResponse);
        MikanUrls.baseUrl = options.uri.origin;
        switch (func) {
          case MikanFunc.season:
            return Resolver.parseSeason(document);
          case MikanFunc.day:
            return Resolver.parseDay(document);
          case MikanFunc.search:
            return Resolver.parseSearch(document);
          case MikanFunc.user:
            return Resolver.parseUser(document);
          case MikanFunc.list:
            return Resolver.parseList(document);
          case MikanFunc.index:
            return Resolver.parseIndex(document);
          case MikanFunc.subgroup:
            return Resolver.parseSubgroup(document);
          case MikanFunc.bangumi:
            return Resolver.parseBangumi(document);
          case MikanFunc.bangumiMore:
            return Resolver.parseBangumiMore(document);
          case MikanFunc.details:
            return Resolver.parseRecordDetail(document);
          case MikanFunc.subscribedSeason:
            return Resolver.parseMySubscribed(document);
          case MikanFunc.refreshLoginToken:
            return Resolver.parseRefreshLoginToken(document);
          case MikanFunc.refreshRegisterToken:
            return Resolver.parseRefreshRegisterToken(document);
          case MikanFunc.refreshForgotPasswordToken:
            return Resolver.parseRefreshForgotPasswordToken(document);
        }
      }

      final extra = options.extra['$ExtraUrl'];
      if (extra == ExtraUrl.fontsManifest) {
        return jsonDecode(transformResponse);
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
    interceptors
      ..add(_BaseInterceptor())
      ..add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          request: false,
          logPrint: (m) => m.$debug(),
        ),
      )
      ..add(CookieManager(PersistCookieJar(storage: FileStorage(cookiesDir))));

    transformer = MikanTransformer();
  }
}

final Future<LoadBalancer> loadBalancer =
    LoadBalancer.create(1, IsolateRunner.spawn);

class _Fetcher {
  factory _Fetcher({
    String? cookiesDir,
  }) {
    _fetcher ??= _Fetcher._(cookiesDir: cookiesDir);
    return _fetcher!;
  }

  _Fetcher._({
    String? cookiesDir,
  }) {
    _http = _Http(cookiesDir: cookiesDir);
  }

  late final _Http _http;
  static _Fetcher? _fetcher;

  static Future<Resp> _asyncInIsolate(_Protocol proto) async {
    final ReceivePort receivePort = ReceivePort();
    final LoadBalancer lb = await loadBalancer;
    await lb.run(_parsingInIsolate, receivePort.sendPort);
    final SendPort sendPort = await receivePort.first;
    final ReceivePort resultPort = ReceivePort();
    proto._sendPort = resultPort.sendPort;
    sendPort.send(proto);
    return await resultPort.first;
  }

  static void _parsingInIsolate(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    receivePort.listen((proto) async {
      try {
        await Jiffy.setLocale('zh_cn');
        final _Http http = _Fetcher(cookiesDir: proto.cookiesDir)._http;
        Response resp;
        if (proto.method == _RequestMethod.get) {
          resp = await http.get(
            proto.url,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.postForm) {
          resp = await http.post(
            proto.url,
            data: FormData.fromMap(proto.data),
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.postJson) {
          resp = await http.post(
            proto.url,
            data: proto.data,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else {
          return proto._sendPort
              .send(Resp(false, msg: 'Not support request method.'));
        }
        if (resp.statusCode == HttpStatus.ok) {
          if (proto.method == _RequestMethod.postForm &&
              (resp.requestOptions.path == MikanUrls.login ||
                  resp.requestOptions.path == MikanUrls.register)) {
            proto._sendPort.send(
              Resp(
                false,
                msg: resp.requestOptions.path == MikanUrls.login
                    ? '登录失败，请检查帐号密码后重试'
                    : '注册失败，请检查表单正确填写后重试',
              ),
            );
          } else {
            proto._sendPort.send(Resp(true, data: resp.data));
          }
        } else {
          proto._sendPort.send(
            Resp(
              false,
              msg: '${resp.statusCode}: ${resp.statusMessage}',
            ),
          );
        }
      } catch (e, s) {
        e.$error(stackTrace: s);
        if (e is DioError) {
          if (e.response?.statusCode == 302 &&
              proto.method == _RequestMethod.postForm &&
              (e.requestOptions.path == MikanUrls.login ||
                  e.requestOptions.path == MikanUrls.register ||
                  e.requestOptions.path == MikanUrls.forgotPassword)) {
            proto._sendPort.send(Resp(true));
          } else {
            proto._sendPort.send(Resp(false, msg: e.message));
          }
        } else {
          proto._sendPort.send(Resp(false, msg: e.toString()));
        }
      }
    });
  }
}

class Http {
  const Http._();

  static Future<Resp> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final proto = _Protocol(
      url,
      _RequestMethod.get,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesPath,
    );
    return _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postForm(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.postForm,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesPath,
    );
    return _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> postJSON(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.postJson,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesPath,
    );
    return _Fetcher._asyncInIsolate(proto);
  }
}

enum _RequestMethod { postForm, postJson, get }

class _Protocol {
  _Protocol(
    this.url,
    this.method, {
    this.data,
    this.queryParameters,
    this.options,
    this.cookiesDir,
  });

  final String url;
  final _RequestMethod method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;

  final String? cookiesDir;
  late SendPort _sendPort;
}

class Resp {
  Resp(this.success, {this.msg, this.data});

  final dynamic data;
  final bool success;
  final String? msg;

  @override
  String toString() {
    return 'Resp{data: $data, success: $success, msg: $msg}';
  }
}
