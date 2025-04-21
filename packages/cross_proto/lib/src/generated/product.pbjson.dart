//
//  Generated code. Do not modify.
//  source: product.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use productDescriptor instead')
const Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'price', '3': 3, '4': 1, '5': 1, '10': 'price'},
    {'1': 'stock', '3': 4, '4': 1, '5': 5, '10': 'stock'},
  ],
};

/// Descriptor for `Product`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productDescriptor = $convert.base64Decode(
    'CgdQcm9kdWN0Eg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhQKBXByaWNlGA'
    'MgASgBUgVwcmljZRIUCgVzdG9jaxgEIAEoBVIFc3RvY2s=');

@$core.Deprecated('Use productQueryDescriptor instead')
const ProductQuery$json = {
  '1': 'ProductQuery',
  '2': [
    {'1': 'keyword', '3': 1, '4': 1, '5': 9, '10': 'keyword'},
    {'1': 'min_price', '3': 2, '4': 1, '5': 1, '10': 'minPrice'},
    {'1': 'max_price', '3': 3, '4': 1, '5': 1, '10': 'maxPrice'},
  ],
};

/// Descriptor for `ProductQuery`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productQueryDescriptor = $convert.base64Decode(
    'CgxQcm9kdWN0UXVlcnkSGAoHa2V5d29yZBgBIAEoCVIHa2V5d29yZBIbCgltaW5fcHJpY2UYAi'
    'ABKAFSCG1pblByaWNlEhsKCW1heF9wcmljZRgDIAEoAVIIbWF4UHJpY2U=');

@$core.Deprecated('Use productListDescriptor instead')
const ProductList$json = {
  '1': 'ProductList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.shop.Product',
      '10': 'items'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `ProductList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productListDescriptor = $convert.base64Decode(
    'CgtQcm9kdWN0TGlzdBIjCgVpdGVtcxgBIAMoCzINLnNob3AuUHJvZHVjdFIFaXRlbXMSFAoFdG'
    '90YWwYAiABKAVSBXRvdGFs');
