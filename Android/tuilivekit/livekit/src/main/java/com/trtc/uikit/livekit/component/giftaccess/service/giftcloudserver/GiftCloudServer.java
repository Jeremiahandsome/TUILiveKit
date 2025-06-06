package com.trtc.uikit.livekit.component.giftaccess.service.giftcloudserver;

import com.google.gson.Gson;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.trtc.uikit.livekit.common.LiveKitLogger;
import com.trtc.uikit.livekit.component.gift.store.model.Gift;
import com.trtc.uikit.livekit.component.gift.store.model.GiftBean;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

public class GiftCloudServer implements IGiftCloudServer {

    private final String mGiftUrl;

    private final List<Gift> mCacheGiftList = new ArrayList<>();

    public GiftCloudServer() {
        mGiftUrl = TUICore.getService("TUIEffectPlayerService") == null
                ? GiftCloudServerConfig.GIFT_DATA_URL : GiftCloudServerConfig.TE_GIFT_DATA_URL;
    }

    @Override
    public void rechargeBalance(Callback<Integer> callback) {

    }

    @Override
    public void queryBalance(Callback<Integer> callback) {

    }

    @Override
    public void queryGiftInfoList(Callback<List<Gift>> callback) {
        if (mCacheGiftList.isEmpty()) {
            queryGiftList((error, result) -> {
                if (error == 0) {
                    synchronized (GiftCloudServer.this) {
                        if (!mCacheGiftList.isEmpty()) {
                            mCacheGiftList.clear();
                        }
                        mCacheGiftList.addAll(result);
                    }
                }
                if (callback != null) {
                    callback.onResult(error, result);
                }
            });
        } else {
            if (callback != null) {
                callback.onResult(Error.NO_ERROR, mCacheGiftList);
            }
        }
    }

    @Override
    public void sendGift(String sender, String receiver, Gift gift, int giftCount, Callback<Integer> callback) {
        if (gift == null || giftCount <= 0) {
            if (callback != null) {
                callback.onResult(Error.PARAM_ERROR, 0);
            }
            return;
        }
        if (callback != null) {
            callback.onResult(Error.NO_ERROR, 0);
        }
    }

    private void queryGiftList(Callback<List<Gift>> callback) {
        HttpGetRequest request = new HttpGetRequest(mGiftUrl, new HttpGetRequest.HttpListener() {
            @Override
            public void onSuccess(String response) {
                Gson gson = new Gson();
                GiftBean giftBean = gson.fromJson(response, GiftBean.class);
                final List<Gift> giftDataList = transformGiftInfoList(giftBean);
                if (giftDataList != null) {
                    if (callback != null) {
                        callback.onResult(Error.NO_ERROR, giftDataList);
                    }
                } else {
                    onFailed("query gift list failed!");
                }
            }

            @Override
            public void onFailed(String message) {
                LiveKitLogger.error(LiveKitLogger.MODULE_COMPONENT, "GiftCloudServer", message);
                if (callback != null) {
                    callback.onResult(IGiftCloudServer.Error.OPERATION_FAILED, Collections.EMPTY_LIST);
                }
            }
        });
        request.execute();
    }

    private List<Gift> transformGiftInfoList(GiftBean giftBean) {
        if (giftBean == null) {
            return null;
        }
        List<GiftBean.GiftListBean> giftBeanList = giftBean.getGiftList();
        if (giftBeanList == null) {
            return null;
        }
        boolean isEnglish = Locale.ENGLISH.getLanguage().equals(TUIThemeManager.getInstance().getCurrentLanguage());
        List<Gift> giftInfoList = new ArrayList<>();
        for (GiftBean.GiftListBean bean : giftBeanList) {
            Gift gift = new Gift();
            gift.giftId = bean.getGiftId();
            gift.giftName = isEnglish ? bean.getGiftNameEn() : bean.getGiftName();
            gift.imageUrl = bean.getImageUrl();
            gift.animationUrl = bean.getAnimationUrl();
            gift.price = bean.getPrice();
            giftInfoList.add(gift);
        }
        return giftInfoList;
    }
}
