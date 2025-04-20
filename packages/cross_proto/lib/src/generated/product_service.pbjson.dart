//
//  Generated code. Do not modify.
//  source: product_service.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'product.pbjson.dart' as $0;

@$core.Deprecated('Use getProductRequestDescriptor instead')
const GetProductRequest$json = {
  '1': 'GetProductRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
  ],
};

/// Descriptor for `GetProductRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProductRequestDescriptor = $convert.base64Decode(
    'ChFHZXRQcm9kdWN0UmVxdWVzdBIOCgJpZBgBIAEoBVICaWQ=');

const $core.Map<$core.String, $core.dynamic> ProductServiceBase$json = {
  '1': 'ProductService',
  '2': [
    {'1': 'QueryProducts', '2': '.shop.ProductQuery', '3': '.shop.ProductList'},
    {'1': 'GetProduct', '2': '.shop.GetProductRequest', '3': '.shop.Product'},
  ],
};

@$core.Deprecated('Use productServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> ProductServiceBase$messageJson = {
  '.shop.ProductQuery': $0.ProductQuery$json,
  '.shop.ProductList': $0.ProductList$json,
  '.shop.Product': $0.Product$json,
  '.shop.GetProductRequest': GetProductRequest$json,
};

/// Descriptor for `ProductService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List productServiceDescriptor = $convert.base64Decode(
    'Cg5Qcm9kdWN0U2VydmljZRI2Cg1RdWVyeVByb2R1Y3RzEhIuc2hvcC5Qcm9kdWN0UXVlcnkaES'
    '5zaG9wLlByb2R1Y3RMaXN0EjQKCkdldFByb2R1Y3QSFy5zaG9wLkdldFByb2R1Y3RSZXF1ZXN0'
    'Gg0uc2hvcC5Qcm9kdWN0');

