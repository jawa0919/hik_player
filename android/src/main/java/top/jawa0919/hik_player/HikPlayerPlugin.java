package top.jawa0919.hik_player;

import androidx.annotation.NonNull;

import com.hikvision.open.hikvideoplayer.HikVideoPlayerFactory;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.platform.PlatformViewRegistry;

/**
 * HikPlayerPlugin
 */
public class HikPlayerPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "hik_player");
        channel.setMethodCallHandler(this);

        HikVideoPlayerFactory.initLib(null, false);

        PlatformViewRegistry r = flutterPluginBinding.getPlatformViewRegistry();
        HikViewFactory f = new HikViewFactory(flutterPluginBinding.getBinaryMessenger());
        r.registerViewFactory("hik_player.viewType", f);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
