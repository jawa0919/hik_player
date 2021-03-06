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
        ThreadUtils.runOnSubThread(() -> {
            handleCall(call, result);
        });
    }

    private void handleCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            //????????????
            case "startRealPlay":
                Config.mPlayType = 1;
                Config.mUrl = methodCall.argument("url");
                callResult(result, startRealPlay());
                break;

            //??????????????????
            case "changeStream":
                Config.mUrl = methodCall.argument("url");
                callResult(result, changeStream());
                break;

            //????????????
            case "startPlayback":
                Config.mPlayType = 2;
                Config.mUrl = methodCall.argument("url");
                Config.mStartTime = methodCall.argument("startTime");
                Config.mStopTime = methodCall.argument("stopTime");
                callResult(result, startPlayback());
                break;

            //???????????????????????????
            case "seekAbsPlayback":
                Config.mSeekTime = methodCall.argument("seekTime");
                callResult(result, seekAbsPlayback());
                break;

            //?????????????????????????????????
            case "getOSDTime":
                callResult(result, getOSDTime());
                break;

            //????????????
            case "pause":
                callResult(result, pause());
                break;

            //????????????
            case "resume":
                callResult(result, resume());
                break;

            //????????????
            case "stopPlay":
                callResult(result, stopPlay());
                break;

            //??????????????????
            case "startVoiceTalk":
                Config.mUrl = methodCall.argument("url");
                callResult(result, startVoiceTalk());
                break;

            //??????????????????
            case "stopVoiceTalk":
                callResult(result, stopVoiceTalk());
                break;

            //??????/?????? ??????
            case "capturePicture":
                Config.mPath = methodCall.argument("path");
                ThreadUtils.runOnUiThread(() -> {
                    callResult(result, capturePicture());
                });
                break;

            //??????????????????
            case "startRecord":
                Config.mPath = methodCall.argument("path");
                callResult(result, startRecord());
                break;

            // ??????????????????
            case "stopRecord":
                callResult(result, stopRecord());
                break;

            //????????????
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
     * ??????????????????
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
     * ??????????????????
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
     * ????????????
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
     * ???????????????????????????
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
     * ?????????????????????????????????
     *
     * @return
     */
    private long getOSDTime() {
        return mPlayer.getOSDTime();
    }

    /**
     * ????????????
     */
    private boolean pause() {
        return mPlayer.pause();
    }

    /**
     * ????????????
     *
     * @return
     */
    private boolean resume() {
        return mPlayer.resume();
    }

    /**
     * ????????????
     */
    private boolean stopPlay() {
        return mPlayer.stopPlay();
    }

    /**
     * ????????????
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
     * ??????????????????
     *
     * @return
     */
    private boolean stopVoiceTalk() {
        return mPlayer.stopVoiceTalk();
    }


    /**
     * ??????/????????????
     *
     * @return
     */
    private boolean capturePicture() {
        Log.i(TAG, "capturePicture: " + Config.mPath);
        return mPlayer.capturePicture(Config.mPath);
    }


    /**
     * ??????????????????
     *
     * @return
     */
    private boolean startRecord() {
        return mPlayer.startRecord(Config.mPath);
    }

    /**
     * ??????????????????
     *
     * @return
     */
    private boolean stopRecord() {
        return mPlayer.stopRecord();
    }

    /**
     * ????????????
     *
     * @return
     */
    private boolean enableSound() {
        return mPlayer.enableSound(mEnable);
    }

    /**
     * ??????????????????
     */
    private void onResume() {
        // ??????:APP?????????????????? SurfaceTextureListener?????????????????? ???????????? ?????????????????????????????????P20????????????????????????????????????
        if (isAvailable()) {
            onSurfaceTextureAvailable(getSurfaceTexture(), getWidth(), getHeight());
        }
    }

    /**
     * ??????????????????
     */
    private void onPause() {
        // ??????:APP?????????????????? SurfaceTextureListener?????????????????? ???????????? ?????????????????????????????????P20????????????????????????????????????
        if (isAvailable()) {
            onSurfaceTextureDestroyed(getSurfaceTexture());
        }
    }


    /**
     * ?????????????????????
     */
    private void updateStatus() {
        ThreadUtils.runOnUiThread(() -> {
            Map<String, Object> ret = new HashMap<>(16);
            ret.put("status", mPlayerStatus);
            if (mPlayerStatus == PlayerStatus.FAILED) {
                ret.put("error", mPlayer.getLastError());
            }
            //?????????????????????
            methodChannel.invokeMethod("onPlayerStatusCallback", ret);
        });
    }

    @Override
    public void onPlayerStatus(HikVideoPlayerCallback.Status status, int i) {
        ThreadUtils.runOnUiThread(() -> {
            switch (status) {
                //????????????
                case SUCCESS:
                    mPlayerStatus = PlayerStatus.SUCCESS;
                    setKeepScreenOn(true);//????????????
                    break;
                //????????????
                case FAILED:
                    mPlayerStatus = PlayerStatus.FAILED;
                    break;
                //??????????????????
                case FINISH:
                    mPlayerStatus = PlayerStatus.FINISH;
                    break;
                //????????????
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
                //????????????
                case SUCCESS:
                    mPlayerStatus = PlayerStatus.SUCCESS;
                    setKeepScreenOn(true);//????????????
                    break;
                //????????????
                case FAILED:
                    mPlayerStatus = PlayerStatus.FAILED;
                    break;
                //??????????????????
                case FINISH:
                    mPlayerStatus = PlayerStatus.FINISH;
                    break;
                //????????????
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
        //???????????????????????????????????????
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
            //??????????????????????????????????????????
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