// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'EasyPlayer 简播';

  @override
  String get developerName => 'PandaSoft 熊猫软件';

  @override
  String get openFile => '打开文件';

  @override
  String get openFolder => '打开文件夹';

  @override
  String get recentlyPlayed => '最近播放';

  @override
  String get clearHistory => '清除播放历史';

  @override
  String get emptyRecentHistory => '暂无播放历史记录';

  @override
  String get play => '播放';

  @override
  String get pause => '暂停';

  @override
  String get stop => '停止';

  @override
  String get nextTrack => '下一首/个';

  @override
  String get previousTrack => '上一首/个';

  @override
  String get seekForward => '快进';

  @override
  String get seekBackward => '快退';

  @override
  String get playbackSpeed => '倍速';

  @override
  String get volume => '音量';

  @override
  String get mute => '静音';

  @override
  String get unmute => '取消静音';

  @override
  String get fullscreen => '全屏';

  @override
  String get exitFullscreen => '退出全屏';

  @override
  String get aspectRatio => '画面比例';

  @override
  String get aspectFit => '适应窗口 (黑边)';

  @override
  String get aspectFill => '铺满屏幕 (裁剪)';

  @override
  String get aspectStretch => '拉伸铺满';

  @override
  String get aspect16_9 => '固定 16:9';

  @override
  String get aspect4_3 => '固定 4:3';

  @override
  String get audioTracks => '音轨选择';

  @override
  String get subtitleTracks => '字幕选择';

  @override
  String get subtitleOff => '关闭字幕';

  @override
  String get subtitleAutoASR => 'AI 离线语音实时字幕';

  @override
  String get subtitleDelay => '字幕时间偏移';

  @override
  String get subtitleSize => '字幕字号';

  @override
  String get subtitleMargin => '字幕纵向位置';

  @override
  String get captions => '字幕';

  @override
  String get transcribing => '正在离线识别语音...';

  @override
  String get modelLoading => '正在加载离线语音引擎...';

  @override
  String get modelDownloading => '正在下载语音模型（约 226 MiB）';

  @override
  String get scriptGenerationNotice => '正在生成字幕脚本，建议等待生成完成...';

  @override
  String get transcriptReady => '字幕已就绪';

  @override
  String get transcriptSidebar => '交互字幕文稿';

  @override
  String get searchTranscript => '在字幕文稿中搜索...';

  @override
  String get loopSentence => '单句复读';

  @override
  String get resumeAutoScroll => '恢复自动滚动';

  @override
  String get exportTranscript => '导出字幕';

  @override
  String get abRepeat => 'A-B 区间复读';

  @override
  String get markerA => 'A 点';

  @override
  String get markerB => 'B 点';

  @override
  String get clearLoop => '清除复读';

  @override
  String get sleepTimer => '睡眠定时器';

  @override
  String get sleepOff => '关闭';

  @override
  String get sleep15m => '15 分钟';

  @override
  String get sleep30m => '30 分钟';

  @override
  String get sleep45m => '45 分钟';

  @override
  String get sleep60m => '60 分钟';

  @override
  String get sleepEndOfTrack => '当前曲目播放完停止';

  @override
  String get sleepCustom => '自定义时长';

  @override
  String get snapshot => '画面截图';

  @override
  String get snapshotSaved => '截图已保存至 Pictures/Screenshots';

  @override
  String get snapshotUnavailableAudio => '音频文件不支持截图';

  @override
  String get settings => '设置';

  @override
  String get generalSettings => '通用设置';

  @override
  String get language => '界面语言';

  @override
  String get followSystem => '跟随系统';

  @override
  String get english => 'English';

  @override
  String get chinese => '简体中文';

  @override
  String get hardwareAcceleration => 'GPU 硬件解码加速';

  @override
  String get loudnessNormalization => '音频响度自动均衡 (Loudnorm)';

  @override
  String get vocalClarityBoost => '人声对白清晰度增强';

  @override
  String get overrideAssStyling => '强制使用标准清晰字幕排版 (覆盖复杂特效)';

  @override
  String get storageAndCache => '存储与缓存管理';

  @override
  String get clearCache => '清除缓存';

  @override
  String get about => '关于 EasyPlayer';

  @override
  String get selectFolder => '选择文件夹';

  @override
  String failedToOpenFile(Object error) {
    return '打开文件失败：$error';
  }

  @override
  String failedToOpenFolder(Object error) {
    return '打开文件夹失败：$error';
  }

  @override
  String get unsupportedMediaFiles => '所选文件夹中没有找到支持的媒体文件。';

  @override
  String get extractingAudio => '正在提取音频...';

  @override
  String get speechRecognitionFailed => '语音识别失败。';

  @override
  String get transcriptMissing => '未找到字幕文件。请使用“开始 AI 转录”按钮生成字幕脚本。';

  @override
  String get startAiTranscription => '开始 AI 转录';

  @override
  String get noTranscriptAvailable => '暂无字幕或转录文本';

  @override
  String get edited => '已编辑';

  @override
  String editCue(Object time) {
    return '编辑字幕（$time）';
  }

  @override
  String get editText => '编辑文本';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get exportAsVtt => '导出为 WebVTT（.vtt）';

  @override
  String get exportAsSrt => '导出为 SubRip（.srt）';

  @override
  String get exportAsText => '导出为纯文本（.txt）';

  @override
  String exportedTo(Object path) {
    return '已导出至：$path';
  }

  @override
  String exportFailed(Object error) {
    return '导出失败：$error';
  }

  @override
  String searchMatches(Object current, Object total) {
    return '第 $current 项，共 $total 项匹配';
  }

  @override
  String get settingsGeneralLocalization => '通用与语言';

  @override
  String get playbackNavigation => '播放与导航';

  @override
  String get audioEnhancements => '音频增强';

  @override
  String get subtitlesAndAsr => '字幕与语音识别（ASR）';

  @override
  String get recordPlaybackHistory => '记录播放历史';

  @override
  String get recordPlaybackHistoryDescription => '将最近打开的媒体保存到“最近播放”列表';

  @override
  String get hardwareAccelerationDescription =>
      '使用 Direct3D / MediaCodec 硬件解码，并在需要时安全回退到 CPU 解码';

  @override
  String get fastBackwardDuration => '快退时长';

  @override
  String get fastForwardDuration => '快进时长';

  @override
  String get seconds => '秒';

  @override
  String get loudnessNormalizationDescription => '自动均衡不同曲目的音量（loudnorm）';

  @override
  String get vocalClarityBoostDescription => '使用高通滤波和人声均衡增强对白清晰度';

  @override
  String get overrideAssStylingDescription =>
      '覆盖 ASS/SSA 粉丝字幕样式，统一使用 EasyPlayer 标准排版';

  @override
  String get showAudioEventTags => '显示音频事件标签';

  @override
  String get showAudioEventTagsDescription => '在字幕中显示 [笑声]、[掌声] 等标签';

  @override
  String get includeSubtitlesInSnapshots => '截图中包含字幕';

  @override
  String get includeSubtitlesInSnapshotsDescription => '截取视频画面时合成当前字幕';

  @override
  String get calculatingStorage => '正在计算存储空间...';

  @override
  String get cachedTranscriptsAndThumbnails => '缓存的字幕与缩略图';

  @override
  String cacheSizeUsed(Object size) {
    return '已使用 $size MB';
  }

  @override
  String get cacheCleared => '缓存已清除。';

  @override
  String get aboutVersion => '版本 1.0.0';

  @override
  String get aboutDescription => '跨平台音视频播放器，支持在设备上离线进行自动语音识别（ASR），无需依赖服务器。';

  @override
  String get copyright => '版权所有 © 2026 PandaSoft。保留所有权利。';

  @override
  String get ok => '确定';

  @override
  String get playlistQueue => '播放队列';

  @override
  String get sequential => '顺序播放';

  @override
  String get single => '单曲循环';

  @override
  String get shuffle => '随机播放';

  @override
  String get noRepeat => '不循环';

  @override
  String get repeatTrack => '循环当前曲目';

  @override
  String get repeatFolder => '循环当前文件夹';

  @override
  String get queueEmpty => '播放队列为空';

  @override
  String get sleepTimerActiveTrack => '定时器已启用：当前曲目结束后停止';

  @override
  String sleepTimerActiveRemaining(Object minutes, Object seconds) {
    return '定时器已启用：剩余 $minutes 分 $seconds 秒';
  }

  @override
  String get turnOffSleepTimer => '关闭睡眠定时器';

  @override
  String get close => '关闭';

  @override
  String get trackVideoSettings => '音轨与画面设置';

  @override
  String get audioSubtitleTracks => '音频与字幕音轨';

  @override
  String get aspectRatioMode => '画面比例模式';

  @override
  String get subtitleSource => '字幕来源';

  @override
  String get sidecarFiles => '外部字幕文件：';

  @override
  String get subtitleTimingOffset => '字幕时间偏移';

  @override
  String get milliseconds => '毫秒';

  @override
  String get subtitleVerticalPosition => '字幕垂直位置';

  @override
  String get subtitleFontSizePoints => '字幕字号';

  @override
  String get points => '点';

  @override
  String get done => '完成';

  @override
  String seekBackwardTooltip(Object seconds) {
    return '后退 $seconds 秒';
  }

  @override
  String seekForwardTooltip(Object seconds) {
    return '前进 $seconds 秒';
  }

  @override
  String get playShortcut => '播放（空格）';

  @override
  String get pauseShortcut => '暂停（空格）';

  @override
  String get abLoopActive => 'A-B 区间循环已启用（按 R 切换）';

  @override
  String get setAbRepeat => '设置 A-B 区间循环（R）';

  @override
  String pointASetAt(Object time) {
    return '已将 A 点设为 $time';
  }

  @override
  String pointBSetAt(Object time) {
    return '已将 B 点设为 $time，开始循环。';
  }

  @override
  String get abLoopCleared => '已清除 A-B 循环';

  @override
  String get closedCaptionsShortcut => '字幕（C）';

  @override
  String get interactiveTranscriptPanel => '交互字幕文稿面板';

  @override
  String get snapshotFrameShortcut => '画面截图（S）';

  @override
  String snapshotSavedPath(Object path) {
    return '截图已保存：$path';
  }

  @override
  String snapshotSaveFailed(Object error) {
    return '截图保存失败：$error';
  }
}
