package top.jawa0919.hik_player;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class HikViewFactory extends PlatformViewFactory {
    private final BinaryMessenger m;

    public HikViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.m = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        return new HikView(context, viewId, args, this.m);
    }
}
