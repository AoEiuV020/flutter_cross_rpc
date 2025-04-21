//
//  Generated code. Do not modify.
//  source: product_service.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'product.pb.dart' as $0;
import 'product_service.pb.dart' as $1;

export 'product_service.pb.dart';

@$pb.GrpcServiceName('shop.ProductService')
class ProductServiceClient extends $grpc.Client {
  static final _$queryProducts =
      $grpc.ClientMethod<$0.ProductQuery, $0.ProductList>(
          '/shop.ProductService/QueryProducts',
          ($0.ProductQuery value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.ProductList.fromBuffer(value));
  static final _$getProduct =
      $grpc.ClientMethod<$1.GetProductRequest, $0.Product>(
          '/shop.ProductService/GetProduct',
          ($1.GetProductRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Product.fromBuffer(value));

  ProductServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.ProductList> queryProducts($0.ProductQuery request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$queryProducts, request, options: options);
  }

  $grpc.ResponseFuture<$0.Product> getProduct($1.GetProductRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getProduct, request, options: options);
  }
}

@$pb.GrpcServiceName('shop.ProductService')
abstract class ProductServiceBase extends $grpc.Service {
  $core.String get $name => 'shop.ProductService';

  ProductServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ProductQuery, $0.ProductList>(
        'QueryProducts',
        queryProducts_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ProductQuery.fromBuffer(value),
        ($0.ProductList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.GetProductRequest, $0.Product>(
        'GetProduct',
        getProduct_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.GetProductRequest.fromBuffer(value),
        ($0.Product value) => value.writeToBuffer()));
  }

  $async.Future<$0.ProductList> queryProducts_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ProductQuery> $request) async {
    return queryProducts($call, await $request);
  }

  $async.Future<$0.Product> getProduct_Pre($grpc.ServiceCall $call,
      $async.Future<$1.GetProductRequest> $request) async {
    return getProduct($call, await $request);
  }

  $async.Future<$0.ProductList> queryProducts(
      $grpc.ServiceCall call, $0.ProductQuery request);
  $async.Future<$0.Product> getProduct(
      $grpc.ServiceCall call, $1.GetProductRequest request);
}
