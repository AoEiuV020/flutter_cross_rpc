//
//  Generated code. Do not modify.
//  source: product_service.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'product.pb.dart' as $0;
import 'product_service.pb.dart' as $1;
import 'product_service.pbjson.dart';

export 'product_service.pb.dart';

abstract class ProductServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ProductList> queryProducts($pb.ServerContext ctx, $0.ProductQuery request);
  $async.Future<$0.Product> getProduct($pb.ServerContext ctx, $1.GetProductRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'QueryProducts': return $0.ProductQuery();
      case 'GetProduct': return $1.GetProductRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'QueryProducts': return this.queryProducts(ctx, request as $0.ProductQuery);
      case 'GetProduct': return this.getProduct(ctx, request as $1.GetProductRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => ProductServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => ProductServiceBase$messageJson;
}

