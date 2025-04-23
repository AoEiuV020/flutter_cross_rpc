import 'package:cross_proto/cross_proto.dart';

class ServiceTest {
  static Future<List<String>> testService(ProductService stub) async {
    final results = <String>[];

    // 测试1：查询所有商品
    results.add('1. 查询所有商品:');
    var response = await stub.queryProducts(ProductQuery());
    results.add('找到 ${response.total} 个商品:');
    for (var product in response.items) {
      results.add('- ${product.name}: ￥${product.price}');
    }

    // 测试2：按关键词搜索
    results.add('\n2. 按关键词搜索 (iPhone):');
    response = await stub.queryProducts(ProductQuery(keyword: 'iphone'));
    results.add('找到 ${response.total} 个商品:');
    for (var product in response.items) {
      results.add('- ${product.name}: ￥${product.price}');
    }

    // 测试3：按价格范围搜索
    results.add('\n3. 按价格范围搜索 (￥500-2000):');
    response = await stub.queryProducts(
      ProductQuery(minPrice: 500, maxPrice: 2000),
    );
    results.add('找到 ${response.total} 个商品:');
    for (var product in response.items) {
      results.add('- ${product.name}: ￥${product.price}');
    }

    // 测试4：获取单个商品
    results.add('\n4. 获取单个商品 (ID: 1):');
    final product = await stub.getProduct(GetProductRequest(id: 1));
    results.add('商品详情:');
    results.add('- ID: ${product.id}');
    results.add('- 名称: ${product.name}');
    results.add('- 价格: ￥${product.price}');
    results.add('- 库存: ${product.stock}');

    // 测试5：测试错误处理
    results.add('\n5. 测试错误处理 - 获取不存在的商品 (ID: 999):');
    try {
      await stub.getProduct(GetProductRequest(id: 999));
    } catch (e) {
      results.add('预期的错误: $e');
    }

    return results;
  }
}
