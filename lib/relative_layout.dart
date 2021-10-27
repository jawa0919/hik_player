/*
 * @FilePath     : /hik_player/lib/relative_layout.dart
 * @Date         : 2021-08-23 11:33:10
 * @Author       : jawa0919 <jawa0919@163.com>
 * @Description  : RelativeLayout
 */

import 'package:flutter/material.dart';

class RelativeLayout extends CustomMultiChildLayout {
  RelativeLayout({
    Key? key,
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          delegate: RelativeLayoutDelegate(
              RelativeLayoutDelegate.generateIds(children)),
          children: children,
        );
}

class ChildLocation {
  Size _size;
  Offset _location;
  Size get size => _size;
  Offset get location => _location;
  ChildLocation(this._size, this._location);
}

enum RelativeOverFlow { inside, overflow }

class RelativeId {
  String id;
  RelativeOverFlow overFlow;

  //默认位置，未指定相对关系的轴将会使用alignment的位置
  Alignment alignment;

  String? toLeftOf;
  String? toRightOf;
  String? below;
  String? above;

  String? alignLeft;
  String? alignRight;
  String? alignTop;
  String? alignBottom;

  RelativeId(
    this.id, {
    this.overFlow = RelativeOverFlow.overflow,
    this.alignment = Alignment.center,
    this.toLeftOf,
    this.toRightOf,
    this.above,
    this.below,
    this.alignLeft,
    this.alignRight,
    this.alignTop,
    this.alignBottom,
  })  : assert(
            isAtMostOneSpecified([toLeftOf, toRightOf, alignLeft, alignRight]),
            'toRightOf、toLeftOf、alignLeft、alignRight can only specify one'),
        assert(isAtMostOneSpecified([above, below, alignTop, alignBottom]),
            'above、below、alignTop、alignBottom can only specify one');

  static bool isAtMostOneSpecified(List<String?> fields) {
    int noNullCount = fields.where((el) => el != null).length;
    return noNullCount <= 1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelativeId && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RelativeLayoutDelegate extends MultiChildLayoutDelegate {
  List<RelativeId> ids;

  Map<RelativeId, ChildLocation> childrenLocations = {};

  RelativeLayoutDelegate(this.ids);

  static generateIds(List<Widget> children) {
    List<RelativeId> ids = children.map((e) {
      assert(e is LayoutId, "RelativeLayout's children must be [LayoutId]");
      assert((e as LayoutId).id is RelativeId,
          "[LayoutId]'s [id] must be [RelativeId]");
      return ((e as LayoutId).id as RelativeId);
    }).toList();
    return ids;
  }

  @override
  void performLayout(Size size) {
    for (RelativeId id in ids) {
      if (hasChild(id)) {
        Size childSize;
        if (id.overFlow == RelativeOverFlow.inside) {
          //如果子布局不能超出父布局，那么它最大宽高不能超过父的宽高
          childSize = layoutChild(id, BoxConstraints.loose(size));
        } else {
          //如果子布局允许超出父布局，那么不限制它的最大宽高
          childSize = layoutChild(id, BoxConstraints());
        }

        //根据alignment的x、y值的含义易知：f(x) = 0.5x + 0.5;
        Alignment alignment = id.alignment;
        double xFraction = (0.5 * alignment.x + 0.5);
        double x = (size.width - childSize.width) * xFraction;

        double yFraction = (0.5 * alignment.y + 0.5);
        double y = (size.height - childSize.height) * yFraction;

        x = convertX(x, id, childSize);
        y = convertY(y, id, childSize);

        if (id.overFlow == RelativeOverFlow.inside) {
          x = x.clamp(0.0, size.width - childSize.width);
          y = y.clamp(0.0, size.height - childSize.height);
        }

        Offset childLocation = Offset(x, y);
        positionChild(id, childLocation);
        childrenLocations[id] = ChildLocation(childSize, childLocation);
      }
    }
  }

  ///x轴转换
  ///[x]默认x值
  ///[id]当前child对应的id
  ///[childSize]当前child的size
  double convertX(double x, RelativeId id, Size childSize) {
    ChildLocation? relativedChildLocation;
    if (id.toLeftOf != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.toLeftOf!)];
      if (relativedChildLocation != null) {
        x = relativedChildLocation.location.dx - childSize.width;
        return x;
      }
    }
    if (id.toRightOf != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.toRightOf!)];
      if (relativedChildLocation != null) {
        x = relativedChildLocation.location.dx +
            relativedChildLocation.size.width;
        return x;
      }
    }
    if (id.alignLeft != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.alignLeft!)];
      if (relativedChildLocation != null) {
        x = relativedChildLocation.location.dx;
        return x;
      }
    }
    if (id.alignRight != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.alignRight!)];
      if (relativedChildLocation != null) {
        x = relativedChildLocation.location.dx +
            relativedChildLocation.size.width -
            childSize.width;
        return x;
      }
    }
    return x;
  }

  ///y轴转换
  ///[y]默认x值
  ///[id]当前child对应的id
  ///[childSize]当前child的size
  double convertY(double y, RelativeId id, Size childSize) {
    ChildLocation? relativedChildLocation;
    if (id.above != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.above!)];
      if (relativedChildLocation != null) {
        y = relativedChildLocation.location.dy - childSize.height;
        return y;
      }
    }
    if (id.below != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.below!)];
      if (relativedChildLocation != null) {
        y = relativedChildLocation.location.dy +
            relativedChildLocation.size.height;
        return y;
      }
    }
    if (id.alignTop != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.alignTop!)];
      if (relativedChildLocation != null) {
        y = relativedChildLocation.location.dy;
        return y;
      }
    }
    if (id.alignBottom != null) {
      relativedChildLocation = childrenLocations[RelativeId(id.alignBottom!)];
      if (relativedChildLocation != null) {
        y = relativedChildLocation.location.dy +
            relativedChildLocation.size.height -
            childSize.height;
        return y;
      }
    }
    return y;
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) {
    childrenLocations.clear();
    return true;
  }
}
