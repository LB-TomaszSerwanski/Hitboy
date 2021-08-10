
#include <AzCore/Memory/SystemAllocator.h>
#include <AzCore/Module/Module.h>

#include "HitboySystemComponent.h"

namespace Hitboy
{
    class HitboyModule
        : public AZ::Module
    {
    public:
        AZ_RTTI(HitboyModule, "{cf4826cf-eedc-4aae-bb06-c5d696f0951a}", AZ::Module);
        AZ_CLASS_ALLOCATOR(HitboyModule, AZ::SystemAllocator, 0);

        HitboyModule()
            : AZ::Module()
        {
            // Push results of [MyComponent]::CreateDescriptor() into m_descriptors here.
            m_descriptors.insert(m_descriptors.end(), {
                HitboySystemComponent::CreateDescriptor(),
            });
        }

        /**
         * Add required SystemComponents to the SystemEntity.
         */
        AZ::ComponentTypeList GetRequiredSystemComponents() const override
        {
            return AZ::ComponentTypeList{
                azrtti_typeid<HitboySystemComponent>(),
            };
        }
    };
}// namespace Hitboy

AZ_DECLARE_MODULE_CLASS(Gem_Hitboy, Hitboy::HitboyModule)
