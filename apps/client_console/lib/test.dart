import 'package:cross_proto/cross_proto.dart';

Future<void> test(ProductService stub) async {
  print('开始测试 $stub ...\n');

  // 测试1：查询所有商品
  print('1. 查询所有商品:');
  var response = await stub.queryProducts(ProductQuery());
  print('找到 ${response.total} 个商品:');
  for (var product in response.items) {
    print('- ${product.name}: ￥${product.price}');
  }

  // 测试2：按关键词搜索
  print('\n2. 按关键词搜索 (iPhone):');
  response = await stub.queryProducts(ProductQuery(keyword: 'iphone'));
  print('找到 ${response.total} 个商品:');
  for (var product in response.items) {
    print('- ${product.name}: ￥${product.price}');
  }

  // 测试3：按价格范围搜索
  print('\n3. 按价格范围搜索 (￥500-2000):');
  response = await stub.queryProducts(
    ProductQuery(minPrice: 500, maxPrice: 2000),
  );
  print('找到 ${response.total} 个商品:');
  for (var product in response.items) {
    print('- ${product.name}: ￥${product.price}');
  }

  // 测试4：获取单个商品
  print('\n4. 获取单个商品 (ID: 1):');
  final product = await stub.getProduct(GetProductRequest(id: 1));
  print('商品详情:');
  print('- ID: ${product.id}');
  print('- 名称: ${product.name}');
  print('- 价格: ￥${product.price}');
  print('- 库存: ${product.stock}');

  // 测试5：测试错误处理 - 获取不存在的商品
  print('\n5. 测试错误处理 - 获取不存在的商品 (ID: 999):');
  try {
    await stub.getProduct(GetProductRequest(id: 999));
  } catch (e) {
    print('预期的错误: $e');
  }
  print('测试完成！$stub\n');
}
