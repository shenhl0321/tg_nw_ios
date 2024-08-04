#import "BusinessFramework.h"
#include <vector>
using namespace std;

static vector<id> listenerVector;
//未广播队列容器
static vector<vector<id>*> notbroadcastlistenerVectorVec;
static BusinessFramework* g_defaultFramework = nil;

@implementation BusinessFramework

+ (id)defaultBusinessFramework
{
    if (g_defaultFramework == nil)
    {
        g_defaultFramework = [[BusinessFramework alloc] init];
    }
    return g_defaultFramework;
}

//释放业务框架资源
+ (void)releaseDefaultBusinessFramework
{
    if (g_defaultFramework)
    {
        [g_defaultFramework release];
        g_defaultFramework = nil;
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {
        businessModuleDict_ = [[NSMutableDictionary alloc] initWithCapacity:10];
        businessListenerArray_ = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}


//注册业务模块
- (void)registerBusinessModule:(id<BusinessModuleProtocol>) businessModule
{
    BusinessModuleInfo* info = [[BusinessModuleInfo alloc] init];
    info.businessFramework = self;
    [businessModule initBusinessModule:info];
    [businessModuleDict_ setValue:businessModule forKey:[NSString stringWithFormat:@"%d", info.businessModuleId]];
}


//注册业务事件监听对象
- (void)registerBusinessListener:(id<BusinessListenerProtocol>) businessListener
{
    listenerVector.push_back(businessListener);
	unsigned long vectorSize = notbroadcastlistenerVectorVec.size();
	for (unsigned long i = 0; i < vectorSize; i++)
    {
		notbroadcastlistenerVectorVec[i]->push_back(businessListener);
	}
}

//取消某个业务事件监听对象
- (void)unregisterBusinessListener:(id<BusinessListenerProtocol>)businessListener
{
    vector<id>::iterator iter;
    for (iter = listenerVector.begin(); iter != listenerVector.end(); iter++)
    {
        if (*iter == businessListener)
        {
            listenerVector.erase(iter);
            break;
        }
    }
	
	unsigned long stackSize = notbroadcastlistenerVectorVec.size();
	for (unsigned long i = 0; i < stackSize; i++)
    {
		vector<id>* notbroadcastlistenerVector = notbroadcastlistenerVectorVec[i];
		vector<id>::iterator notbroadcastlistenerVectorIter;
		
		for (notbroadcastlistenerVectorIter = notbroadcastlistenerVector->begin();
			 notbroadcastlistenerVectorIter != notbroadcastlistenerVector->end();
			 notbroadcastlistenerVectorIter++)
        {
			if (*notbroadcastlistenerVectorIter == businessListener)
            {
				notbroadcastlistenerVector->erase(notbroadcastlistenerVectorIter);
				break;
			}
		}
	}
}

//在所有业务事件监听对象上广播业务通知
- (void)broadcastBusinessNotify:(int)notifcationId withInParam:(id)inParam
{
	vector<id>* notbroadcastlistenerVector = new vector<id>(listenerVector);
	notbroadcastlistenerVectorVec.push_back(notbroadcastlistenerVector);
	
	while (notbroadcastlistenerVector->begin() != notbroadcastlistenerVector->end())
    {
		id<BusinessListenerProtocol> listener = *notbroadcastlistenerVector->begin();
		//NSLog(@"listen 0x(%x)", listener);
		notbroadcastlistenerVector->erase(notbroadcastlistenerVector->begin());
		
		//NSLog(@"listener class %@", [listenerVector CLASS])
		[listener processBusinessNotify:notifcationId withInParam:inParam];
	}
	notbroadcastlistenerVectorVec.pop_back();
	delete notbroadcastlistenerVector;
	notbroadcastlistenerVector = NULL;
}

//调用具体某个业务处理，需要返回输出参数
- (int)callBusinessProcess:(int)funcId withInParam:(id)inParam andOutParam:(id*)outParam
{
    NSString* key = [NSString stringWithFormat:@"%d", ModuleID(funcId)];
    id<BusinessModuleProtocol> module =  [businessModuleDict_ valueForKey:key];
    if (module)
    {
        return [module callBusinessProcess:CapabilityID(funcId) withInParam:inParam andOutParam:outParam];
    }
    return -1;
}

- (int)callBusinessDataProcess:(int)funcId withInParam:(id)inParam andOutParam:(id*)outParam
{
	NSString* key = [NSString stringWithFormat:@"%d", ModuleID(funcId)];
    id<BusinessModuleProtocol> module =  [businessModuleDict_ valueForKey:key];
    if (module)
    {
        return [module callBusinessDataProcess:CapabilityID(funcId) withInParam:inParam andOutParam:outParam];
    }
    return -1;
}


//调用具体某个业务处理，不需要返回输出参数
- (int)callBusinessProcess:(int)funcId withInParam:(id)inParam
{
    return [self callBusinessProcess:funcId withInParam:inParam andOutParam:nil];
}

- (void)dealloc
{
    //[businessModuleDict_ removeAllObjects];
    [businessModuleDict_ release];
    businessModuleDict_ = nil;
    
    //[businessListenerArray_ removeAllObjects];
    [businessListenerArray_ release];
    businessListenerArray_ = nil;
    
    listenerVector.clear();
    [super dealloc];
}

@end
