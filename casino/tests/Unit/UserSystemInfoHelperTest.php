<?php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;
use VanguardLTE\Helpers\UserSystemInfoHelper;

class UserSystemInfoHelperTest extends TestCase
{
    protected function tearDown(): void
    {
        // Clean up any server vars we set during tests
        unset($_SERVER['HTTP_USER_AGENT'], $_SERVER['HTTP_ACCEPT'], $_SERVER['HTTP_X_WAP_PROFILE'], $_SERVER['HTTP_PROFILE']);
        parent::tearDown();
    }

    public function test_get_os_detects_windows_10(): void
    {
        $_SERVER['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
        $this->assertSame('Windows 10', UserSystemInfoHelper::get_os());
    }

    public function test_get_browsers_detects_chrome(): void
    {
        $_SERVER['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
        $this->assertSame('Chrome', UserSystemInfoHelper::get_browsers());
    }

    public function test_get_device_detects_mobile(): void
    {
        $_SERVER['HTTP_USER_AGENT'] = 'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36';
        $_SERVER['HTTP_ACCEPT'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,application/vnd.wap.xhtml+xml;q=0.1';
        $this->assertSame('Mobile', UserSystemInfoHelper::get_device());
    }
}

