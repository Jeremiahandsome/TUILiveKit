package com.trtc.uikit.livekit.livestream.view.anchor;

import static com.trtc.uikit.livekit.livestream.view.anchor.TUILiveRoomAnchorFragment.RoomBehavior.CREATE_ROOM;
import static com.trtc.uikit.livekit.livestream.view.anchor.TUILiveRoomAnchorFragment.RoomBehavior.ENTER_ROOM;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.trtc.tuikit.common.FullScreenActivity;
import com.trtc.uikit.livekit.R;
import com.trtc.uikit.livekit.livestream.view.VideoLiveKitImpl;

public class VideoLiveAnchorActivity extends FullScreenActivity implements VideoLiveKitImpl.CallingAPIListener {

    public static final String INTENT_KEY_ROOM_ID     = "intent_key_room_id";
    public static final String INTENT_KEY_NEED_CREATE = "intent_key_need_create";

    @Override
    protected void attachBaseContext(Context context) {
        super.attachBaseContext(context);
        if (context != null) {
            Configuration configuration = context.getResources().getConfiguration();
            configuration.fontScale = 1;
            applyOverrideConfiguration(configuration);
        }
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(null);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        String roomId = getIntent().getStringExtra(INTENT_KEY_ROOM_ID);
        boolean needCreateRoom = getIntent().getBooleanExtra(INTENT_KEY_NEED_CREATE, true);
        setContentView(R.layout.livekit_activity_video_live_anchor);
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        TUILiveRoomAnchorFragment anchorFragment = new TUILiveRoomAnchorFragment(roomId, needCreateRoom ?
                CREATE_ROOM : ENTER_ROOM);
        fragmentTransaction.add(R.id.fl_container, anchorFragment);
        fragmentTransaction.commit();

        VideoLiveKitImpl.createInstance(getApplicationContext()).addCallingAPIListener(this);
    }

    @Override
    protected void onDestroy() {
        VideoLiveKitImpl.createInstance(getApplicationContext()).removeCallingAPIListener(this);
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
    }

    @Override
    public void onLeaveLive() {
        finish();
    }

    @Override
    public void onStopLive() {
        finish();
    }
}
