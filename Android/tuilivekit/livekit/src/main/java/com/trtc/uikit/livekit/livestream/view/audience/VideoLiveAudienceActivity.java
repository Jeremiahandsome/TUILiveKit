package com.trtc.uikit.livekit.livestream.view.audience;

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

public class VideoLiveAudienceActivity extends FullScreenActivity implements VideoLiveKitImpl.CallingAPIListener {

    public static final String INTENT_KEY_ROOM_ID = "intent_key_room_id";

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
        setContentView(R.layout.livekit_activity_video_live_audience);
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        TUILiveRoomAudienceFragment audienceFragment = new TUILiveRoomAudienceFragment(roomId);
        fragmentTransaction.add(R.id.fl_container, audienceFragment);
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