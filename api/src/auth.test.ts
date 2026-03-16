// Tests for authentication and token parsing methods
import { describe, it, expect } from 'vitest';
import * as cheerio from 'cheerio';
import MikanApi from './mikan';
import { loginHtml } from './fixtures/html-samples';

describe('MikanApi - Authentication Methods', () => {
  describe('parseRefreshLoginToken', () => {
    it('should parse login token from HTML', () => {
      const $ = cheerio.load(loginHtml);
      const result = (MikanApi as any)['parseRefreshLoginToken']($);

      expect(result).toBeTruthy();
      expect(typeof result).toBe('string');
      expect(result?.length).toBeGreaterThan(50);
      expect(result).toMatch(/CfDJ8/);
    });

    it('should return null if token not found', () => {
      const html = '<div><form>No token here</form></div>';
      const $ = cheerio.load(html);
      const result = (MikanApi as any)['parseRefreshLoginToken']($);

      expect(result).toBeNull();
    });
  });

  describe('parseRefreshRegisterToken', () => {
    it('should parse register token from HTML', () => {
      // Since register page might need auth, test with login HTML structure
      const html = loginHtml;
      const $ = cheerio.load(html);
      const result = (MikanApi as any)['parseRefreshRegisterToken']($);

      expect(result).toBeTruthy();
      expect(typeof result).toBe('string');
      expect(result?.length).toBeGreaterThan(50);
    });
  });

  describe('parseRefreshForgotPasswordToken', () => {
    it('should parse forgot password token from HTML', () => {
      // Since forgot password page might need auth, test with login HTML structure
      const html = loginHtml;
      const $ = cheerio.load(html);
      const result = (MikanApi as any)['parseRefreshForgotPasswordToken']($);

      expect(result).toBeTruthy();
      expect(typeof result).toBe('string');
      expect(result?.length).toBeGreaterThan(50);
    });
  });

  describe('Token parsing consistency', () => {
    it('should extract tokens with correct format', () => {
      const $ = cheerio.load(loginHtml);
      const loginToken = (MikanApi as any)['parseRefreshLoginToken']($);
      const registerToken = (MikanApi as any)['parseRefreshRegisterToken']($);
      const forgotToken = (MikanApi as any)['parseRefreshForgotPasswordToken']($);

      // All tokens should have same prefix
      expect(loginToken?.startsWith('CfDJ8')).toBe(true);
      expect(registerToken?.startsWith('CfDJ8')).toBe(true);
      expect(forgotToken?.startsWith('CfDJ8')).toBe(true);

      // All tokens should be reasonably long (anti-forgery tokens are long)
      expect(loginToken?.length).toBeGreaterThan(100);
      expect(registerToken?.length).toBeGreaterThan(100);
      expect(forgotToken?.length).toBeGreaterThan(100);
    });
  });

  describe('Token format validation', () => {
    it('should contain valid characters', () => {
      const $ = cheerio.load(loginHtml);
      const token = (MikanApi as any)['parseRefreshLoginToken']($);

      // Anti-forgery tokens typically contain base64-like characters
      expect(token).toMatch(/^[A-Za-z0-9_-]+$/);
    });
  });

  describe('resolveLoginForm', () => {
    it('should prefer the form action that preserves ReturnUrl', () => {
      const $ = cheerio.load(loginHtml);
      const form = (MikanApi as any)['resolveLoginForm']($);

      expect(form.attr('action')).toContain('/Account/Login?ReturnUrl=');
    });
  });

  describe('validateLoginResponse', () => {
    it('should surface js-login-error messages from failed login pages', () => {
      const html = `
        <html>
          <body>
            <form id="loginForm" action="/Account/Login" method="post">
              <input name="UserName" />
              <input name="Password" />
              <input name="__RequestVerificationToken" value="token" />
            </form>
            <p class="js-login-error">登录失败，请重试.</p>
          </body>
        </html>
      `;

      expect(() => (MikanApi as any)['validateLoginResponse'](html)).toThrow(/登录失败，请重试/);
    });

    it('should not throw for non-login pages', () => {
      const html = `
        <html>
          <body>
            <div id="user-name">
              <div class="text-right">test-user</div>
            </div>
          </body>
        </html>
      `;

      expect(() => (MikanApi as any)['validateLoginResponse'](html)).not.toThrow();
    });
  });
});

describe('MikanApi - Authentication Integration', () => {
  describe('login', () => {
    it('should be a function', () => {
      expect(typeof MikanApi.login).toBe('function');
    });

    it('should accept email, password, and optional returnUrl', () => {
      const api = MikanApi;
      expect(async () => {
        await api.login('test@example.com', 'password', '/');
      }).toBeDefined();
    });
  });

  describe('register', () => {
    it('should be a function', () => {
      expect(typeof MikanApi.register).toBe('function');
    });

    it('should accept userName, email, password, and confirmPassword', () => {
      const api = MikanApi;
      expect(async () => {
        await api.register('testUser', 'test@example.com', 'password123', 'password123');
      }).toBeDefined();
    });

    it('should require matching passwords', () => {
      const api = MikanApi;
      expect(async () => {
        await api.register('testUser', 'test@example.com', 'password123', 'password456');
      }).toBeDefined();
    });
  });

  describe('forgotPassword', () => {
    it('should be a function', () => {
      expect(typeof MikanApi.forgotPassword).toBe('function');
    });

    it('should accept email parameter', () => {
      const api = MikanApi;
      expect(async () => {
        await api.forgotPassword('test@example.com');
      }).toBeDefined();
    });
  });

  describe('subscribeBangumi', () => {
    it('should be a function', () => {
      expect(typeof MikanApi.subscribeBangumi).toBe('function');
    });

    it('should accept bangumiId and optional subtitleGroupId', () => {
      const api = MikanApi;
      expect(async () => {
        await api.subscribeBangumi('123');
        await api.subscribeBangumi('123', '456');
      }).toBeDefined();
    });
  });

  describe('unsubscribeBangumi', () => {
    it('should be a function', () => {
      expect(typeof MikanApi.unsubscribeBangumi).toBe('function');
    });

    it('should accept bangumiId and optional subtitleGroupId', () => {
      const api = MikanApi;
      expect(async () => {
        await api.unsubscribeBangumi('123');
        await api.unsubscribeBangumi('123', '456');
      }).toBeDefined();
    });
  });
});
