package com.techind.flutter_sharing_intent

import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE)
class FlutterSharingIntentPluginTest {

    private lateinit var plugin: FlutterSharingIntentPlugin

    @Before
    fun setUp() {
        plugin = FlutterSharingIntentPlugin()
    }

    @Test
    fun getMediaType_returnsFile_forNullPath() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.FILE, plugin.getMediaType(null))
    }

    @Test
    fun getMediaType_returnsFile_forPathWithNoExtension() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.FILE, plugin.getMediaType("/path/to/filewithoutextension"))
    }

    @Test
    fun getMediaType_returnsImage_forJpgFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.IMAGE, plugin.getMediaType("/path/to/photo.jpg"))
    }

    @Test
    fun getMediaType_returnsImage_forPngFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.IMAGE, plugin.getMediaType("/path/to/image.png"))
    }

    @Test
    fun getMediaType_returnsImage_forGifFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.IMAGE, plugin.getMediaType("/path/to/animation.gif"))
    }

    @Test
    fun getMediaType_returnsText_forTxtFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.TEXT, plugin.getMediaType("/path/to/document.txt"))
    }

    @Test
    fun getMediaType_returnsText_forHtmlFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.TEXT, plugin.getMediaType("/path/to/page.html"))
    }

    @Test
    fun getMediaType_returnsFile_forPdfFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.FILE, plugin.getMediaType("/path/to/document.pdf"))
    }

    @Test
    fun getMediaType_returnsFile_forDocxFile() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.FILE, plugin.getMediaType("/path/to/document.docx"))
    }

    @Test
    fun getMediaType_returnsFile_forUnknownExtension() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.FILE, plugin.getMediaType("/path/to/file.unknownxyz123"))
    }

    @Test
    fun getMediaType_returnsVideo_forMp4File() {
        assertEquals(FlutterSharingIntentPlugin.MediaType.VIDEO, plugin.getMediaType("/path/to/clip.mp4"))
    }
}
