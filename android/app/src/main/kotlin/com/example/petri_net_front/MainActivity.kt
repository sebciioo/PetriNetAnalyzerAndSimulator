package com.example.petri_net_front

import android.os.Bundle
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Inicjalizacja Chaquopy
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "chaquopy")
            .setMethodCallHandler { call, result ->
                if (call.method == "start_server") {
                    try {
                        val py = Python.getInstance()
                        val pyModule = py.getModule("main") 
                        pyModule.callAttr("main") // Wywołanie funkcji start_server
                        result.success("Serwer Flask został uruchomiony.")
                    } catch (e: Exception) {
                        result.error("error", "Błąd uruchamiania serwera Flask", e.message)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
