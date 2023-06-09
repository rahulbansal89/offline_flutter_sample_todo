// ignore_for_file: unnecessary_null_comparison

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/services/hive_service.dart';
import 'package:todo_app/services/settings_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Global options
final cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: HiveCacheStore(Settings().getDirectory()?.path ?? ''),

  // All subsequent fields are optional.

  // Default.
  policy: CachePolicy.refreshForceCache,
  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  hitCacheOnErrorExcept: [401, 403],
  // Overrides any HTTP directive to delete entry past this duration.
  // Useful only when origin server has no cache config or custom behaviour is desired.
  // Defaults to [null].
  maxStale: const Duration(days: 7),
  // Default. Allows 3 cache sets and ease cleanup.
  priority: CachePriority.normal,
  // Default. Body and headers encryption with your own algorithm.
  cipher: null,
  // Default. Key builder to retrieve requests.
  keyBuilder: CacheOptions.defaultCacheKeyBuilder,
  // Default. Allows to cache POST requests.
  // Overriding [keyBuilder] is strongly recommended when [true].
  allowPostMethod: true,
);

/// Dio Client gives instance for Dio Http Client
class DioClient {
  Dio _dio = Dio();
  BaseOptions options = BaseOptions(
    receiveTimeout: const Duration(seconds: 10000),
    sendTimeout: const Duration(seconds: 10000),
  );

  DioClient() {
    getTemporaryDirectory();
    _dio = Dio(options);
    _dio.interceptors.add(DioInterceptors());
    _dio.interceptors.add(DioCacheInterceptor(
      options: cacheOptions,
    ));
  }

  Dio get httpClient {
    return _dio;
  }
}

/// Dio Interceptors override default interceptors
class DioInterceptors extends Interceptor {
  @override
  FutureOr<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // add latest headers on request
    handler.next(options);
  }

  @override
  FutureOr<dynamic> onError(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
  }

  @override
  FutureOr<dynamic> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    handler.next(response);
  }
}

Future<bool> checkUserConnection() async {
  try {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  } catch (_) {
    return false;
  }
}

class Api {
  static Future<dynamic> get(
    String url,
  ) async {
    DioClient dioClient = DioClient();
    try {
      final Response response = await dioClient.httpClient.get(
        'https://my-json-server.typicode.com/flutterdata/demo/$url',
      );

      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) rethrow;
    }
    return null;
  }

  static Future<dynamic> post(
    String url, {
    dynamic data,
  }) async {
    DioClient dioClient = DioClient();
    try {
      if (!await checkUserConnection()) {
        Box box = HiveService().getBox();
        List writeCalls = box.get('writeCalls') ?? [];
        Map writeCall = {
          'url': url,
          'data': data,
        };
        writeCalls.add(writeCall);
        box.put('writeCalls', writeCalls);
        return null;
      }

      final Response response = await dioClient.httpClient.post(
        'https://my-json-server.typicode.com/flutterdata/demo/$url',
        data: data,
      );
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) rethrow;
    }
    return null;
  }

  static Future<dynamic> patch(
    String url, {
    dynamic data,
  }) async {
    DioClient dioClient = DioClient();
    try {
      if (!await checkUserConnection()) {
        Box box = HiveService().getBox();
        List patchCalls = box.get('patchCalls') ?? [];
        Map patchCall = {
          'url': url,
          'data': data,
        };
        patchCalls.add(patchCall);
        box.put('patchCalls', patchCalls);
        return null;
      }

      final Response response = await dioClient.httpClient.patch(
        'https://my-json-server.typicode.com/flutterdata/demo/$url',
        data: data,
      );
      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) rethrow;
    }
    return null;
  }

  static Future<dynamic> delete(
    String url,
  ) async {
    DioClient dioClient = DioClient();
    try {
      if (!await checkUserConnection()) {
        Box box = HiveService().getBox();
        List delCalls = box.get('delCalls') ?? [];
        delCalls.add(url);
        box.put('delCalls', delCalls);
        return null;
      }

      final Response response = await dioClient.httpClient.delete(
        'https://my-json-server.typicode.com/flutterdata/demo/$url',
      );

      return response;
    } catch (e, stackTrace) {
      if (kDebugMode) rethrow;
    }
    return null;
  }
}
