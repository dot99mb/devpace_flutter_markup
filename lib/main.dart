import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

Future<Size> _calculateImageDimension() {
  Completer<Size> completer = Completer();
  Image image = Image.asset('assets/images/logo.png');
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _calculateImageDimension();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevPace FA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter MARKUP'),
    );
  }
}

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var myChildSize = Size.zero;
  var myLogoSize = Size.zero;
  List<String> itemList =
      List<String>.generate(0, (index) => ('Item # ${(index + 1)}'));

  void _addOneItem() {
    itemList.add('Item # ${itemList.length + 1}');
    setState(() {});
  }

  Widget getLogoWidget(sizeheight) {
    var image = Image.asset(
      'assets/images/logo.png',
    );
    double margin = 30;
    return Container(
      height: myLogoSize == Size.zero
          ? null
          : max(sizeheight - margin * 2 - myChildSize.height,
              myLogoSize.height - margin * 2),
      margin: EdgeInsets.all(margin),
      child: Center(
        child: image,
      ),
    );
  }

  Widget getItemsWidget() {
    return Container(
      // decoration: BoxDecoration(border: Border.all()),
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          childAspectRatio: 2,
        ),
        itemCount: itemList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            //margin: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.amber,
              border: Border.all(width: 1, color: Colors.black),
            ),
            child: Center(child: Text(itemList[index])),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar();

    final sizeheight = MediaQuery.of(context).size.height -
        appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addOneItem,
        child: const FittedBox(
          child: Text('+1 item'),
        ),
      ),
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            //LOGO
            MeasureSize(
              onChange: (size) {
                if (myLogoSize == Size.zero) {
                  setState(() {
                    myLogoSize = size;
                  });
                }
              },
              child: getLogoWidget(sizeheight),
            ),

            //Items
            if (itemList.isNotEmpty)
              MeasureSize(
                onChange: (size) {
                  setState(() {
                    myChildSize = size;
                  });
                },
                child: getItemsWidget(),
              ),
          ],
        ),
      ),
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
