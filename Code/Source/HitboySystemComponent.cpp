
#include <AzCore/Serialization/SerializeContext.h>
#include <AzCore/Serialization/EditContext.h>
#include <AzCore/Serialization/EditContextConstants.inl>

#include "HitboySystemComponent.h"

namespace Hitboy
{
    void HitboySystemComponent::Reflect(AZ::ReflectContext* context)
    {
        if (AZ::SerializeContext* serialize = azrtti_cast<AZ::SerializeContext*>(context))
        {
            serialize->Class<HitboySystemComponent, AZ::Component>()
                ->Version(0)
                ;

            if (AZ::EditContext* ec = serialize->GetEditContext())
            {
                ec->Class<HitboySystemComponent>("Hitboy", "[Description of functionality provided by this System Component]")
                    ->ClassElement(AZ::Edit::ClassElements::EditorData, "")
                        ->Attribute(AZ::Edit::Attributes::AppearsInAddComponentMenu, AZ_CRC("System"))
                        ->Attribute(AZ::Edit::Attributes::AutoExpand, true)
                    ;
            }
        }
    }

    void HitboySystemComponent::GetProvidedServices(AZ::ComponentDescriptor::DependencyArrayType& provided)
    {
        provided.push_back(AZ_CRC("HitboyService"));
    }

    void HitboySystemComponent::GetIncompatibleServices(AZ::ComponentDescriptor::DependencyArrayType& incompatible)
    {
        incompatible.push_back(AZ_CRC("HitboyService"));
    }

    void HitboySystemComponent::GetRequiredServices([[maybe_unused]] AZ::ComponentDescriptor::DependencyArrayType& required)
    {
    }

    void HitboySystemComponent::GetDependentServices([[maybe_unused]] AZ::ComponentDescriptor::DependencyArrayType& dependent)
    {
    }
    
    HitboySystemComponent::HitboySystemComponent()
    {
        if (HitboyInterface::Get() == nullptr)
        {
            HitboyInterface::Register(this);
        }
    }

    HitboySystemComponent::~HitboySystemComponent()
    {
        if (HitboyInterface::Get() == this)
        {
            HitboyInterface::Unregister(this);
        }
    }

    void HitboySystemComponent::Init()
    {
    }

    void HitboySystemComponent::Activate()
    {
        HitboyRequestBus::Handler::BusConnect();
    }

    void HitboySystemComponent::Deactivate()
    {
        HitboyRequestBus::Handler::BusDisconnect();
    }
}
