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
import 'package:mikan_flutter/base/store.dart';
import 'package:mikan_flutter/internal/consts.dart';
import 'package:mikan_flutter/internal/extension.dart';
import 'package:mikan_flutter/internal/logger.dart';
import 'package:mikan_flutter/internal/resolver.dart';

class _BaseInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    final int timeout = Duration(minutes: 1).inMilliseconds;
    options.baseUrl = MikanUrl.BASE_URL;
    options.connectTimeout = timeout;
    options.receiveTimeout = timeout;
    options.headers["user-agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/86.0.4240.75 Safari/537.36 "
        "MikanFlutter/unlimited";
    options.headers['upgrade-insecure-requests'] = 1;
    options.headers['client'] = "mikan_flutter";
    options.headers['os'] = Platform.operatingSystem;
    options.headers['os-version'] = Platform.operatingSystemVersion;
    return options;
  }
}

class MikanTransformer extends DefaultTransformer {
  @override
  Future transformResponse(
    RequestOptions options,
    ResponseBody response,
  ) async {
    final transformResponse = await super.transformResponse(options, response);
    final String func = options.extra["$MikanFunc"];
    if (func.isNotBlank && transformResponse is String) {
      final Document document = parse(transformResponse);
      switch (func) {
        case MikanFunc.SEASON:
          return await Resolver.parseSeason(document);
          break;
        case MikanFunc.DAY:
          return await Resolver.parseDay(document);
          break;
        case MikanFunc.SEARCH:
          return await Resolver.parseSearch(document);
          break;
        case MikanFunc.USER:
          return await Resolver.parseUser(document);
          break;
        case MikanFunc.LIST:
          return await Resolver.parseList(document);
          break;
        case MikanFunc.INDEX:
          return await Resolver.parseIndex(document);
          break;
        case MikanFunc.SUBGROUP:
          return await Resolver.parseSubgroup(document);
          break;
        case MikanFunc.BANGUMI:
          return await Resolver.parseBangumi(document);
          break;
        case MikanFunc.BANGUMI_MORE:
          return await Resolver.parseBangumiMore(document);
          break;
        case MikanFunc.DETAILS:
          return await Resolver.parseRecordDetail(document);
          break;
        case MikanFunc.SUBSCRIBED_SEASON:
          return await Resolver.parseMySubscribed(document);
          break;
      }
    }
    return transformResponse;
  }
}

class _Http extends DioForNative {
  _Http({
    String cacheDir,
    String deviceModel,
    String appVersion,
    BaseOptions options,
  }) : super(options) {
    // this.httpClientAdapter = Http2Adapter(ConnectionManager());
    this.interceptors
      ..add(_BaseInterceptor())
      ..add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          request: false,
          error: true,
          logPrint: (obj) => logd(obj),
        ),
      )
      ..add(
        CookieManager(
          PersistCookieJar(dir: cacheDir + "/cookies"),
        ),
      );

    this.transformer = MikanTransformer();
  }
}

final Future<LoadBalancer> loadBalancer =
    LoadBalancer.create(1, IsolateRunner.spawn);

class _Fetcher {
  _Http _http;
  static _Fetcher _fetcher;

  factory _Fetcher({
    String cacheDir,
    String deviceModel,
    String appVersion,
  }) {
    if (_fetcher == null) {
      _fetcher = _Fetcher._(
        cacheDir: cacheDir,
        deviceModel: deviceModel,
        appVersion: appVersion,
      );
    }
    return _fetcher;
  }

  _Fetcher._({
    final String cacheDir,
    final String deviceModel,
    final String appVersion,
  }) {
    _http = _Http(
      cacheDir: cacheDir,
      deviceModel: deviceModel,
      appVersion: appVersion,
    );
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
        final _Http http = _Fetcher(
          cacheDir: proto.cacheDir,
          deviceModel: proto.deviceModel,
          appVersion: proto.appVersion,
        )._http;
        Response resp;
        if (proto.method == _RequestMethod.GET) {
          resp = await http.get(
            proto.url,
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else if (proto.method == _RequestMethod.POST) {
          resp = await http.post(
            proto.url,
            data: FormData.fromMap(proto.data),
            queryParameters: proto.queryParameters,
            options: proto.options,
          );
        } else {
          return proto._sendPort
              .send(Resp(false, msg: "Not support request method."));
        }
        if (resp.statusCode == HttpStatus.ok) {
          proto._sendPort.send(Resp(true, data: resp.data));
        } else {
          proto._sendPort.send(
            Resp(false,
                msg: "Request error! Http status："
                    "${resp.statusCode} => ${resp.statusMessage}"),
          );
        }
      } catch (e) {
        logd(e);
        if (e is DioError &&
            e.response.statusCode == 302 &&
            e.request.path == MikanUrl.LOGIN) {
          proto._sendPort.send(Resp(true));
        } else {
          proto._sendPort.send(Resp(false, msg: e?.message));
        }
      }
    });
  }
}

class Http {
  const Http._();

  static Future<Resp> get(
    final String url, {
    final Map<String, dynamic> queryParameters,
    final Options options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.GET,
      queryParameters: queryParameters,
      options: options,
      cacheDir: Store.cacheDir.path,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }

  static Future<Resp> post(
    final String url, {
    final data,
    final Map<String, dynamic> queryParameters,
    final Options options,
  }) async {
    final _Protocol proto = _Protocol(
      url,
      _RequestMethod.POST,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cacheDir: Store.cacheDir.path,
    );
    return await _Fetcher._asyncInIsolate(proto);
  }
}

enum _RequestMethod { POST, GET }

class _Protocol {
  final String url;
  final _RequestMethod method;
  final data;
  final Map<String, dynamic> queryParameters;
  final Options options;

  final String cacheDir;
  final String deviceModel;
  final String appVersion;
  SendPort _sendPort;

  _Protocol(
    this.url,
    this.method, {
    this.data,
    this.queryParameters,
    this.options,
    this.cacheDir,
    this.deviceModel,
    this.appVersion,
  });
}

class Resp {
  final dynamic data;
  final bool success;
  final String msg;

  Resp(this.success, {this.msg, this.data});

  @override
  String toString() {
    return 'Resp{data: $data, success: $success, msg: $msg}';
  }
}
