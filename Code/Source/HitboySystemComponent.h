
#pragma once

#include <AzCore/Component/Component.h>

#include <Hitboy/HitboyBus.h>

namespace Hitboy
{
    class HitboySystemComponent
        : public AZ::Component
        , protected HitboyRequestBus::Handler
    {
    public:
        AZ_COMPONENT(HitboySystemComponent, "{b2b95eca-86b3-4d8d-8a83-e42dc17ab7d0}");

        static void Reflect(AZ::ReflectContext* context);

        static void GetProvidedServices(AZ::ComponentDescriptor::DependencyArrayType& provided);
        static void GetIncompatibleServices(AZ::ComponentDescriptor::DependencyArrayType& incompatible);
        static void GetRequiredServices(AZ::ComponentDescriptor::DependencyArrayType& required);
        static void GetDependentServices(AZ::ComponentDescriptor::DependencyArrayType& dependent);

        HitboySystemComponent();
        ~HitboySystemComponent();

    protected:
        ////////////////////////////////////////////////////////////////////////
        // HitboyRequestBus interface implementation

        ////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////
        // AZ::Component interface implementation
        void Init() override;
        void Activate() override;
        void Deactivate() override;
        ////////////////////////////////////////////////////////////////////////
    };
}
