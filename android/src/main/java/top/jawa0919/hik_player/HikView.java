package top.jawa0919.hik_player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.text.TextUtils;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.UiThread;

import com.hikvision.open.hikvideoplayer.HikVideoPlayer;
import com.hikvision.open.hikvideoplayer.HikVideoPlayerCallback;
import com.hikvision.open.hikvideoplayer.HikVideoPlayerFactory;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

@SuppressLint("ViewConstructor")
public class HikView extends TextureView implements TextureView.SurfaceTextureListener, PlatformView, MethodChannel.MethodCallHandler, HikVideoPlayerCallback, HikVideoPlayerCallback.VoiceTalkCallback {
    static class Config {
        static String mUrl;
        static String mStartTime;
        static String mStopTime;
        static String mSeekTime;
        static String mPath;
        static int mPlayType = 0;
    }

    public interface PlayerStatus {
        int IDLE = 0;
        int LOADING = 1;
        int SUCCESS = 2;
        int STOPPING = 3;
        int FAILED = 4;
        int EXCEPTION = 5;
        int FINISH = 6;
    }

    private static final String TAG = "HikView";

    private final HikVideoPlayer mPlayer;
    private int mPlayerStatus = PlayerStatus.IDLE;

    private final MethodChannel methodChannel;
    private boolean mEnable;

    public HikView(Context context, int viewId, Object args, BinaryMessenger messenger) {
        super(context);
        setLayoutParams(new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setSurfaceTextureListener(this);
        mPlayer = HikVideoPlayerFactory.provideHikVideoPlayer();

        methodChannel = new MethodChannel(messenger, "hik_controller_" + viewId);
        methodChannel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
//       if (call.method.equals("capturePicture")) {
//           Log.i(TAG, "onMethodCall: capturePicture");
//           Config.mPath = call.argument("path");
//           result.success(capturePicture());
//        //    callResult(result, capturePicture());
//           return;
//       }
        ThreadUtils.runOnSubThread(() -> {
            handleCall(call, result);
        });
    }

    private void handleCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            //开始预览
            case "startRealPlay":
                Config.mPlayType = 1;
                Config.mUrl = methodCall.argument("url");
                callResult(result, startRealPlay());
                break;

            //码流平滑切换
            case "changeStream":
                Config.mUrl = methodCall.argument("url");
                callResult(result, changeStream());
                break;

            //开始回放
            case "startPlayback":
                Config.mPlayType = 2;
                Config.mUrl = methodCall.argument("url");
                Config.mStartTime = methodCall.argument("startTime");
                Config.mStopTime = methodCall.argument("stopTime");
                callResult(result, startPlayback());
                break;

            //按绝对时间回放定位
            case "seekAbsPlayback":
                Config.mSeekTime = methodCall.argument("seekTime");
                callResult(result, seekAbsPlayback());
                break;

            //查询当前播放时间戳接口
            case "getOSDTime":
                callResult(result, getOSDTime());
                break;

            //暂停回放
            case "pause":
                callResult(result, pause());
                break;

            //恢复回放
            case "resume":
                callResult(result, resume());
                break;

            //停止播放
            case "stopPlay":
                callResult(result, stopPlay());
                break;

            //开启语音对讲
            case "startVoiceTalk":
                Config.mUrl = methodCall.argument("url");
                callResult(result, startVoiceTalk());
                break;

            //关闭语音对讲
            case "stopVoiceTalk":
                callResult(result, stopVoiceTalk());
                break;

            //预览/回放 抓图
            case "capturePicture":
                Config.mPath = methodCall.argument("path");
                callResult(result, capturePicture());
                break;

            //开启本地录像
            case "startRecord":
                Config.mPath = methodCall.argument("path");
                callResult(result, startRecord());
                break;

            // 关闭本地录像
            case "stopRecord":
                callResult(result, stopRecord());
                break;

            //声音控制
            case "enableSound":
                mEnable = methodCall.argument("enable");
                callResult(result, enableSound());
                break;

            case "onResume":
                onResume();
                callResult(result, true);
                break;

            case "onPause":
                onPause();
                callResult(result, true);
                break;

            default:
                ThreadUtils.runOnUiThread(result::notImplemented);
        }
    }

    private void callResult(MethodChannel.Result result, Object o) {
        HashMap<String, Object> ret = new HashMap<>(16);
        ret.put("ret", o);
        ThreadUtils.runOnUiThread(() -> {
            result.success(ret);
        });
    }

    /**
     * 开始实时预览
     */
    private boolean startRealPlay() {
        mPlayerStatus = PlayerStatus.LOADING;
        updateStatus();

        SurfaceTexture texture = getSurfaceTexture();
        if (texture == null) {
            onPlayerStatus(Status.FAILED, -1);
            return false;
        }
        mPlayer.setSurfaceTexture(texture);
        if (TextUtils.isEmpty(Config.mUrl)) {
            onPlayerStatus(Status.FAILED, -1);
            return false;
        }
        boolean ret = mPlayer.startRealPlay(Config.mUrl, this);
        if (!ret) {
            onPlayerStatus(Status.FAILED, mPlayer.getLastError());
        }
        return ret;
    }

    /**
     * 码流平滑切换
     */
    private boolean changeStream() {
        if (TextUtils.isEmpty(Config.mUrl)) {
            onPlayerStatus(Status.FAILED, -1);
            return false;
        }
        boolean ret = mPlayer.changeStream(Config.mUrl, this);
        if (!ret) {
            onPlayerStatus(Status.FAILED, mPlayer.getLastError());
        }
        return ret;
    }

    /**
     * 开始回放
     */
    private boolean startPlayback() {
        mPlayerStatus = PlayerStatus.LOADING;
        updateStatus();

        SurfaceTexture texture = getSurfaceTexture();
        if (texture == null) {
            onPlayerStatus(Status.FAILED, -1);
            return false;
        }
        mPlayer.setSurfaceTexture(texture);
        if (TextUtils.isEmpty(Config.mUrl)) {
            onPlayerStatus(Status.FAILED, -1);
            return false;
        }
        boolean ret = mPlayer.startPlayback(Config.mUrl, Config.mStartTime, Config.mStopTime, this);
        if (!ret) {
            onPlayerStatus(Status.FAILED, mPlayer.getLastError());
        }
        return ret;
    }

    /**
     * 按绝对时间回放定位
     */
    private boolean seekAbsPlayback() {
        mPlayerStatus = PlayerStatus.LOADING;
        updateStatus();

        boolean ret = mPlayer.seekAbsPlayback(Config.mSeekTime, this);
        if (!ret) {
            onPlayerStatus(Status.FAILED, mPlayer.getLastError());
        }
        return ret;
    }

    /**
     * 查询当前播放时间戳接口
     *
     * @return
     */
    private long getOSDTime() {
        return mPlayer.getOSDTime();
    }

    /**
     * 暂停回放
     */
    private boolean pause() {
        return mPlayer.pause();
    }

    /**
     * 恢复回放
     *
     * @return
     */
    private boolean resume() {
        return mPlayer.resume();
    }

    /**
     * 停止播放
     */
    private boolean stopPlay() {
        return mPlayer.stopPlay();
    }

    /**
     * 开启对讲
     */
    private boolean startVoiceTalk() {
        mPlayerStatus = PlayerStatus.LOADING;
        updateStatus();

        if (TextUtils.isEmpty(Config.mUrl)) {
            onTalkStatus(Status.FAILED, -1);
            return false;
        }
        boolean ret = mPlayer.startVoiceTalk(Config.mUrl, this);
        if (!ret) {
            onTalkStatus(Status.FAILED, mPlayer.getLastError());
        }
        return ret;
    }


    /**
     * 关闭语音对讲
     *
     * @return
     */
    private boolean stopVoiceTalk() {
        return mPlayer.stopVoiceTalk();
    }


    /**
     * 预览/回放抓图
     *
     * @return
     */
    private boolean capturePicture() {
        Log.i(TAG, "capturePicture: " + Config.mPath);
        return mPlayer.capturePicture(Config.mPath);
    }


    /**
     * 开启本地录像
     *
     * @return
     */
    private boolean startRecord() {
        return mPlayer.startRecord(Config.mPath);
    }

    /**
     * 关闭本地录像
     *
     * @return
     */
    private boolean stopRecord() {
        return mPlayer.stopRecord();
    }

    /**
     * 声音控制
     *
     * @return
     */
    private boolean enableSound() {
        return mPlayer.enableSound(mEnable);
    }

    /**
     * 生命周期管理
     */
    private void onResume() {
        // 注意:APP前后台切换时 SurfaceTextureListener可能在有某些 华为手机 上不会回调，例如：华为P20，所以我们在这里手动调用
        if (isAvailable()) {
            onSurfaceTextureAvailable(getSurfaceTexture(), getWidth(), getHeight());
        }
    }

    /**
     * 生命周期管理
     */
    private void onPause() {
        // 注意:APP前后台切换时 SurfaceTextureListener可能在有某些 华为手机 上不会回调，例如：华为P20，所以我们在这里手动调用
        if (isAvailable()) {
            onSurfaceTextureDestroyed(getSurfaceTexture());
        }
    }


    /**
     * 更新播放器状态
     */
    private void updateStatus() {
        ThreadUtils.runOnUiThread(() -> {
            Map<String, Object> ret = new HashMap<>(16);
            ret.put("status", mPlayerStatus);
            if (mPlayerStatus == PlayerStatus.FAILED) {
                ret.put("error", mPlayer.getLastError());
            }
            //上传播放器状态
            methodChannel.invokeMethod("onPlayerStatusCallback", ret);
        });
    }

    @Override
    public void onPlayerStatus(HikVideoPlayerCallback.Status status, int i) {
        ThreadUtils.runOnUiThread(() -> {
            switch (status) {
                //播放成功
                case SUCCESS:
                    mPlayerStatus = PlayerStatus.SUCCESS;
                    setKeepScreenOn(true);//保持亮屏
                    break;
                //播放失败
                case FAILED:
                    mPlayerStatus = PlayerStatus.FAILED;
                    break;
                //录像回放结束
                case FINISH:
                    mPlayerStatus = PlayerStatus.FINISH;
                    break;
                //取流异常
                case EXCEPTION:
                    mPlayerStatus = PlayerStatus.EXCEPTION;
                    mPlayer.stopPlay();
                    break;
                default:
                    mPlayerStatus = PlayerStatus.IDLE;
                    mPlayer.stopPlay();
            }
            updateStatus();
        });
    }

    @Override
    public void onTalkStatus(Status status, int i) {
        ThreadUtils.runOnUiThread(() -> {
            switch (status) {
                //播放成功
                case SUCCESS:
                    mPlayerStatus = PlayerStatus.SUCCESS;
                    setKeepScreenOn(true);//保持亮屏
                    break;
                //播放失败
                case FAILED:
                    mPlayerStatus = PlayerStatus.FAILED;
                    break;
                //录像回放结束
                case FINISH:
                    mPlayerStatus = PlayerStatus.FINISH;
                    break;
                //取流异常
                case EXCEPTION:
                    mPlayerStatus = PlayerStatus.EXCEPTION;
                    mPlayer.stopPlay();
                    break;
                default:
                    mPlayerStatus = PlayerStatus.IDLE;
                    mPlayer.stopPlay();
            }
            updateStatus();
        });
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        //恢复处于暂停播放状态的窗口
        if (mPlayerStatus == PlayerStatus.STOPPING) {
            switch (Config.mPlayType) {
                case 1:
                    startRealPlay();
                    break;
                case 2:
                    startPlayback();
                    break;
                default:
            }

        }
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        if (mPlayerStatus == PlayerStatus.SUCCESS) {
            //暂停播放，再次进入时恢复播放
            mPlayerStatus = PlayerStatus.STOPPING;
            updateStatus();
            mPlayer.stopPlay();
        }
        return false;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {

    }


    @Override
    public View getView() {
        return this;
    }

    @Override
    public void dispose() {
        mPlayer.stopPlay();
    }
}