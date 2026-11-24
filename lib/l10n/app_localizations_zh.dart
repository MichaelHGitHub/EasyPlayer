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
  String get snapshotSaved => '原画截图已保存至 Pictures/EasyPlayer';

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
}
