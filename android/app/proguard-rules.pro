# tflite_flutter GPU delegate ixtiyoriy (tensorflow-lite-gpu dependency qo'shilmagan,
# faqat CPU bilan ishlatamiz) — R8 reflection orqali shu klasslarni topa olmaydi.
# Keep emas, dontwarn — runtimeda chaqirilmasa ham build'ni to'xtatmasin.
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
