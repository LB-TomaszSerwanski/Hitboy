
#pragma once

#include <AzCore/EBus/EBus.h>
#include <AzCore/Interface/Interface.h>

namespace Hitboy
{
    class HitboyRequests
    {
    public:
        AZ_RTTI(HitboyRequests, "{f19060fd-2c48-4e1f-aae1-23ea65120b96}");
        virtual ~HitboyRequests() = default;
        // Put your public methods here
    };
    
    class HitboyBusTraits
        : public AZ::EBusTraits
    {
    public:
        //////////////////////////////////////////////////////////////////////////
        // EBusTraits overrides
        static constexpr AZ::EBusHandlerPolicy HandlerPolicy = AZ::EBusHandlerPolicy::Single;
        static constexpr AZ::EBusAddressPolicy AddressPolicy = AZ::EBusAddressPolicy::Single;
        //////////////////////////////////////////////////////////////////////////
    };

    using HitboyRequestBus = AZ::EBus<HitboyRequests, HitboyBusTraits>;
    using HitboyInterface = AZ::Interface<HitboyRequests>;

} // namespace Hitboy
