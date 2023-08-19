import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:html/parser.dart';
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
    options.followRedirects = true;
    options.headers['user-agent'] =
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/113.0.0.0 '
        'Safari/537.36 '
        'MikanProject/1.0.0';
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
    ResponseBody responseBody,
  ) async {
    final rep = await super.transformResponse(options, responseBody);
    if (rep is String) {
      final String? func = options.extra['$MikanFunc'];
      if (func.isNotBlank) {
        final document = parse(rep);
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
        return jsonDecode(rep);
      }
    }
    return rep;
  }
}

class _Http extends DioForNative {
  _Http({
    String? cookiesDir,
    BaseOptions? options,
  }) : super(options) {
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

class Http {
  const Http._();

  static _Http? _http;

  static Future<Resp> _request(_CallOptions options) async {
    MikanUrls.baseUrl = options.mikanBaseUrl;
    await Jiffy.setLocale('zh_cn');
    _http ??= _Http(cookiesDir: options.cookiesDir);
    try {
      Response resp;
      if (options.method == _InnerMethod.get) {
        resp = await _http!.get(
          options.url,
          queryParameters: options.queryParameters,
          options: options.options,
        );
      } else if (options.method == _InnerMethod.form) {
        resp = await _http!.post(
          options.url,
          data: FormData.fromMap(options.data),
          queryParameters: options.queryParameters,
          options: options.options,
        );
      } else if (options.method == _InnerMethod.json) {
        resp = await _http!.post(
          options.url,
          data: options.data,
          queryParameters: options.queryParameters,
          options: options.options,
        );
      } else {
        return Resp.error('Not support request method.');
      }
      if (resp.statusCode == HttpStatus.ok) {
        if (options.method == _InnerMethod.form &&
            (resp.requestOptions.path == MikanUrls.login ||
                resp.requestOptions.path == MikanUrls.register)) {
          return Resp.error(
            resp.requestOptions.path == MikanUrls.login
                ? '登录失败，请检查帐号密码后重试'
                : '注册失败，请检查表单正确填写后重试',
          );
        } else {
          return Resp.ok(resp.data);
        }
      } else {
        return Resp.error(
          '${resp.statusCode}: ${resp.statusMessage}',
        );
      }
    } catch (e, s) {
      e.$error(stackTrace: s);
      if (e is DioException) {
        if (e.response?.statusCode == 302 &&
            options.method == _InnerMethod.form &&
            (e.requestOptions.path == MikanUrls.login ||
                e.requestOptions.path == MikanUrls.register ||
                e.requestOptions.path == MikanUrls.forgotPassword)) {
          return Resp.ok();
        } else {
          return Resp.error(e.message);
        }
      } else {
        return Resp.error(e.toString());
      }
    }
  }

  static Future<Resp> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final proto = _CallOptions(
      url,
      _InnerMethod.get,
      mikanBaseUrl: MikanUrls.baseUrl,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesDir,
    );
    return Isolate.run(() => _request(proto));
  }

  static Future<Resp> form(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    final _CallOptions proto = _CallOptions(
      url,
      _InnerMethod.form,
      mikanBaseUrl: MikanUrls.baseUrl,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesDir,
    );
    return Isolate.run(() => _request(proto));
  }

  static Future<Resp> json(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final _CallOptions proto = _CallOptions(
      url,
      _InnerMethod.json,
      mikanBaseUrl: MikanUrls.baseUrl,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cookiesDir: MyHive.cookiesDir,
    );
    return Isolate.run(() => _request(proto));
  }
}

enum _InnerMethod { form, json, get }

class _CallOptions {
  _CallOptions(
    this.url,
    this.method, {
    this.data,
    this.queryParameters,
    this.options,
    this.cookiesDir,
    required this.mikanBaseUrl,
  });

  final String url;
  final String mikanBaseUrl;
  final _InnerMethod method;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final Options? options;

  final String? cookiesDir;
}

class Resp {
  Resp._(this.success, {this.msg, this.data});

  factory Resp.ok([Object? data]) {
    return Resp._(true, data: data);
  }

  factory Resp.error([String? msg]) {
    return Resp._(false, msg: msg);
  }

  final dynamic data;
  final bool success;
  final String? msg;

  @override
  String toString() {
    return 'Resp{data: $data, success: $success, msg: $msg}';
  }
}
