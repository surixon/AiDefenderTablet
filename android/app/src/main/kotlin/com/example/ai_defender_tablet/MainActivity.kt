package com.example.ai_defender_tablet

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.annotation.NonNull
import com.example.ai_defender_tablet.models.Device
import com.stealthcopter.networktools.PortScan
import com.stealthcopter.networktools.SubnetDevices
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.net.InetAddress
import java.net.NetworkInterface


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ai.defender/wifi"
    private lateinit var channel: MethodChannel
    private val REQUEST_OVERLAY_PERMISSION = 101;


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        ).setMethodCallHandler { call, result ->
            channel = MethodChannel(getBinaryMessenger(), CHANNEL)
            when (call.method) {
                "startScan" -> {

                    try {


                        SubnetDevices.fromLocalAddress().findDevices(object :
                            SubnetDevices.OnSubnetDeviceFound {
                            override fun onDeviceFound(device: com.stealthcopter.networktools.subnet.Device?) {

                            }

                            override fun onFinished(results: ArrayList<com.stealthcopter.networktools.subnet.Device?>?) {
                                val devices = arrayListOf<Device>()
                                results?.forEach {
                                    PortScan.onAddress(it?.ip).setTimeOutMillis(1).setPortsAll()
                                        .setMethodTCP()
                                        .doScan(object : PortScan.PortListener {
                                            override fun onResult(p0: Int, p1: Boolean) {

                                            }

                                            override fun onFinished(p0: java.util.ArrayList<Int>?) {

                                                val device = Device(it?.ip, it?.mac, p0!!)
                                                Log.d(
                                                    "Devices",
                                                    """${device.name}   ${device.address}  """
                                                )

                                            }
                                        })


                                }

                                result.success(devices)
                            }
                        })


                    } catch (e: Exception) {
                        e.fillInStackTrace()
                    }

                }

                "getMacAddressFromIpAddress" -> {
                    //result.success(ARPInfo.getMACFromIPAddress(call.arguments.toString()))
                    //result.success(getMacAddressFromIpAddress(call.arguments.toString()))
                    result.success(getDeviceMacAddress(call.arguments.toString()))
                }

                "overlayPermission" -> {
                    overlayPermission()
                }

                else -> {
                    result.notImplemented()
                }
            }
        }

    }


    private fun getBinaryMessenger(): BinaryMessenger {
        return flutterEngine!!.dartExecutor.binaryMessenger
    }


    private fun getMacAddressFromIpAddress(ipAddress: String): String {
        val wifiManager =
            context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val dhcpInfo = wifiManager.dhcpInfo
        val ipInt = dhcpInfo.ipAddress

        if (ipInt != 0) {
            val ip = String.format(
                "%d.%d.%d.%d",
                (ipInt and 0xff),
                (ipInt shr 8 and 0xff),
                (ipInt shr 16 and 0xff),
                (ipInt shr 24 and 0xff)
            )
            if (ip == ipAddress) {
                val wifiInfo: WifiInfo? = wifiManager.connectionInfo
                return wifiInfo?.macAddress ?: ""
            }
        }

        return ""
    }

    private fun getDeviceMacAddress(ipAddress: String?): String {
        try {
            val localIP = InetAddress.getByName(ipAddress)
            val networkInterface = NetworkInterface.getByInetAddress(localIP) ?: return ""
            val hardwareAddress = networkInterface.hardwareAddress ?: return ""
            val stringBuilder = StringBuilder(18)
            for (b in hardwareAddress) {
                if (stringBuilder.isNotEmpty()) {
                    stringBuilder.append(":")
                }
                stringBuilder.append(String.format("%02x", b))
            }
            return stringBuilder.toString()
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
        return ""
    }


    private fun overlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && !Settings.canDrawOverlays(this)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )

            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
        }
    }
}

