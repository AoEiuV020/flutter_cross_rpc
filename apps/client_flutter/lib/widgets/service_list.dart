import 'package:flutter/material.dart';

import '../service_manager.dart';

class ServiceList extends StatelessWidget {
  final ServiceManager serviceManager;

  const ServiceList({super.key, required this.serviceManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: serviceManager,
      builder: (context, _) {
        if (!serviceManager.hasServices) {
          return const Center(child: Text('还未添加任何服务'));
        }

        return ListView.builder(
          itemCount: serviceManager.allServices.length,
          itemBuilder: (context, index) {
            final entry = serviceManager.allServices.entries.elementAt(index);
            return ListTile(
              leading: const Icon(Icons.api),
              title: Text(entry.key),
              subtitle: Text(entry.value.runtimeType.toString()),
            );
          },
        );
      },
    );
  }
}
