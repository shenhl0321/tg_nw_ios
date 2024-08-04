//
//  CString.h
//  moorgeniPad
//
//  Created by moorgen on 2017/3/15.
//  Copyright © 2017年 moorgen. All rights reserved.
//
/**
 *  此.h用来放常用字符串
 **/
#ifndef CString_h
#define CString_h

//#define LocalString(text) [text mn_localizedString]
#define LocalString(text) text.lv_localized
//#define LocalString(string)  NSLocalizedString(string, nil)
/**关于设备的*/
static NSString * const localAppName = APP_NAME;

#pragma mark - 20211110-
static NSString * const  localMessage = @"消息";
static NSString * const localAddressBook = @"通讯录";
static NSString * const localFind = @"发现";
static NSString * const localExplore = @"探索";
static NSString * const localMe = @"我的";
static NSString * const localContactPerson = @"联系人";
static NSString * const localVerificationCode = @"验证码";
static NSString * const localGetVerificationCode = @"获取验证码";
static NSString * const localPlsEnterPhoneNum = @"请输入手机号码";
static NSString * const localPlsEnterVerificationCode = @"请输入验证码";
static NSString * const localAccountLogin = @"账号登录";
static NSString * const localPasswordLogin = @"密码登录";
static NSString * const localRegisterAccount = @"注册账号";
static NSString * const localLogin = @"登录";
static NSString * const localPlsEnterLoginAccount = @"请输入登录账号";
static NSString * const localPlsEnterLoginPwd = @"请输入登录密码";
//static NSString * const localPlsAccountName = @"请输入用户名（5位以上字母数字组合）";
//static NSString * const localPlsSetNewLoginPwd = @"请设置6-20位新的登录密码";
static NSString * const localPlsReEnterNewLoginPwd = @"请再次输入新的登录密码";
static NSString * const localNextStep = @"下一步";
static NSString * const localSetNikename = @"设置昵称";
static NSString * const localPlsEnterNikename = @"请输入昵称";
//static NSString * const localPlsEnter = @"请再次输入新密码";
static NSString * const localCountryCode = @"国家码";
static NSString * const localResentK = @"重新发送(%ld)";
static NSString * const localPlsReEnterNewPwd = @"请再次输入新密码";
static NSString * const localSure = @"确定";
static NSString * const localOldPwd = @"原密码";
static NSString * const localNewPwd = @"新密码";
static NSString * const localEnsurePwd = @"确认密码";
static NSString * const localPlsEnterNewPwd = @"请输入新密码";
//static NSString * const localPlsReEnterNewPwd = @"请再次输入新密码";
static NSString * const localSetPwd = @"设置密码";
static NSString * const localSetRestSuccess = @"设置/重置成功";
static NSString * const localYouSetResetSuccess = @"您已设置/重置成功";
static NSString * const localFinish = @"完成";
static NSString * const localCommit = @"提交";
static NSString * const localVerificationCodeSended = @"验证码已发送到您的手机";
static NSString * const localVerificationCodeLogin = @"验证码登录";
static NSString * const localSearch = @"搜索";
static NSString * const localCancel = @"取消";
static NSString * const localPlsChooseCountry = @"请选择国家";

static NSString * const localPlsEnterUserNameLimit = @"请输入用户名(5位以上字母数字组合)";
static NSString * const localPlsSetLimitLoginPwd = @"请设置6-20位新的登录密码";
static NSString * const localPlsEnterInviteCode = @"请输入邀请码";
static NSString * const localPlsEnterCorrectPhoneNum = @"请输入正确的手机号码";
static NSString * const localPlsEnterCorrectUserName = @"请输入正确的用户名";
static NSString * const localPlsEnterCorrectLoginPwd = @"请输入正确的登录密码";
static NSString * const localPlsEnterCorrectInviteCode = @"请输入正确的邀请码";
static NSString * const localPlsEnterYourNickName = @"请输入您的昵称";
static NSString * const localEnterSmsCode = @"输入短信验证码";
static NSString * const localPlsEnterCorretSmsCode = @"请输入正确的短信验证码";
static NSString * const localSmsCodeSended_K_ = @"短信验证码已经发送至%@ %@";
static NSString * const localTop = @"置顶";
static NSString * const localCancelTop = @"取消置顶";
static NSString * const localArchive = @"归档";
static NSString * const localOpenNoti = @"打开通知";
static NSString * const localNoNoti = @"免打扰";
static NSString * const localDelete = @"删除";
static NSString * const localSending = @"发送中...";
static NSString * const localSendFailed = @"发送失败";
//static NSString * const local = @"";
//static NSString * const local = @"";
//static NSString * const local = @"";
//static NSString * const local = @"";
//static NSString * const local = @"";
//static NSString * const local = @"";
#endif /* CString_h */
