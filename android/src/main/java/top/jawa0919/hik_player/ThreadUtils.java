package top.jawa0919.hik_player;

import android.os.Handler;
import android.os.Looper;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class ThreadUtils {
    /**
     * 初始化主线程handler
     */
    private static Handler mHandler = new Handler(Looper.getMainLooper());
    /**
     * 初始化单线程的线程池执行器
     */
    private static ExecutorService mExecutor = Executors.newFixedThreadPool(10);

    private ThreadUtils() {
    }

    /**
     * 切换到主线程执行任务
     *
     * @param r
     */
    public static void runOnUiThread(Runnable r) {
        if (isOnUIThread()) {
            r.run();
        } else {
            mHandler.post(r);
        }
    }

    /**
     * 切换到子线程执行任务
     *
     * @param r
     */
    public static void runOnSubThread(Runnable r) {
        if (!isOnUIThread()) {
            r.run();
        } else {
            mExecutor.submit(r);
        }
    }

    /**
     * 判断是当前线程是否是UI线程
     *
     * @return true表示UI线程, false表示子线程
     */
    public static boolean isOnUIThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    /**
     * 线程池
     */
    private static ThreadPoolExecutor threadPool;

    /**
     * 获取线单例程池
     *
     * @return
     */
    public static ThreadPoolExecutor getThreadPool() {
        if (threadPool == null) {
            synchronized (ThreadUtils.class) {
                if (threadPool == null) {
                    threadPool = new ThreadPoolExecutor(
                            5,
                            200,
                            0L,
                            TimeUnit.MILLISECONDS,
                            new LinkedBlockingQueue<Runnable>(1024),
                            new ThreadPoolExecutor.AbortPolicy());
                }
            }
        }

        return threadPool;
    }

    /**
     * 使用线程池执行任务(无返回值)
     *
     * @param r
     */
    public static void execute(Runnable r) {
        getThreadPool().execute(r);
    }

    /**
     * 使用线程池执行任务(有返回值,可取消)
     *
     * @param callable
     * @param <T>
     * @return
     */
    public static <T> Future<T> submit(Callable<T> callable) {
        return getThreadPool().submit(callable);
    }
}
