import 'dart:io';

import 'package:dio/dio.dart';

/// تبدیل هر خطا به پیام فارسی قابل نمایش برای کاربر.
/// قرارداد سرور: همه‌ی خطاها با شکل `{ "error": "..." }` برمی‌گردند.
String friendlyError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'اتصال به سرور ممکن نیست؛ اینترنت خود را بررسی کنید';
      case DioExceptionType.connectionError:
        return 'اتصال به سرور برقرار نشد؛ اینترنت خود را بررسی کنید';
      case DioExceptionType.cancel:
        return 'عملیات لغو شد';
      default:
        break;
    }

    final data = error.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }

    switch (error.response?.statusCode) {
      case 401:
        return 'نشست شما منقضی شده است. دوباره وارد شوید';
      case 403:
        return 'شما اجازه‌ی این عملیات را ندارید';
      case 404:
        return 'مورد درخواستی یافت نشد';
    }

    final code = error.response?.statusCode;
    if (code != null && code >= 500) {
      return 'خطای داخلی سرور؛ کمی بعد دوباره تلاش کنید';
    }
  }

  return error.toString().replaceFirst('Exception: ', '');
}

/// آیا این خطا یعنی «شبکه در دسترس نیست» (ارزش صف‌شدن/فال‌بک آفلاین دارد)؟
/// خطاهای ۴xx/۵xx سرور صف نمی‌شوند — فقط قطعی/تایم‌اوت.
bool isNetworkError(Object e) {
  if (e is DioException) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };
  }
  return e is SocketException;
}
