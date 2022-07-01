import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/counter.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    final provider = CounterProvider.of(context);
    final Product product =
        ModalRoute.of(context)!.settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(
        title: const Text('product.title'),
      ),
      body: Column(
        children: [
          Text(provider?.state.value.toString() ?? '0'),
          IconButton(
            onPressed: () {
              setState(() {
                provider?.state.inc();
              });
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                provider?.state.dec();
              });
            },
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
