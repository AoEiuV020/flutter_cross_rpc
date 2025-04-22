import 'package:cross_proto/cross_proto.dart';
import 'package:cross_wrapper/cross_wrapper.dart';
import 'package:grpc/grpc.dart';

void main() async {
  // 创建 gRPC channel
  final channel = ClientChannel(
    'localhost',
    port: 8888,
    options: ChannelOptions(
      credentials: const ChannelCredentials.insecure(),
      codecRegistry: CodecRegistry(
        codecs: const [GzipCodec(), IdentityCodec()],
      ),
      idleTimeout: Duration(minutes: 1),
    ),
  );

  // 创建 stub
  final ProductService stub = ProductServiceWrapper(
    ProductServiceClient(channel),
  );

  try {
    print('开始测试 gRPC 客户端...\n');

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
  } catch (e) {
    print('发生错误: $e');
  } finally {
    // 关闭 channel
    await channel.shutdown();
  }
}
