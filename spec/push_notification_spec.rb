describe "push notifications" do
  before { @subject = AppDelegate.new }

  it "should handle push notifications" do

    @subject.mock!(:on_push_notification) do |notification, was_launched|
      notification.should.be.kind_of(ProMotion::PushNotification)
      notification.alert.should == "Eating Bacon"
      notification.badge.should == 42
      notification.sound.should == "jamon"
      @subject.aps_notification.should == notification
    end

    launch_options = { UIApplicationLaunchOptionsRemoteNotificationKey => ProMotion::PushNotification.fake_notification(alert: "Eating Bacon", badge: 42, sound: "jamon").notification }
    @subject.application(UIApplication.sharedApplication, willFinishLaunchingWithOptions: nil)
    @subject.application(UIApplication.sharedApplication, didFinishLaunchingWithOptions:launch_options )

  end

  it "should return the registered push notification types as an array" do
    @subject.registered_push_notifications.should == []
    bits = 0
    types = []
    { badge:      UIRemoteNotificationTypeBadge,
      sound:      UIRemoteNotificationTypeSound,
      alert:      UIRemoteNotificationTypeAlert,
      newsstand:  UIRemoteNotificationTypeNewsstandContentAvailability }.each do |symbol, bit|
        UIApplication.sharedApplication.stub!(:enabledRemoteNotificationTypes, return: bit)
        @subject.registered_push_notifications.should == [symbol]

        bits |= bit
        types << symbol
        UIApplication.sharedApplication.stub!(:enabledRemoteNotificationTypes, return: bits)
        @subject.registered_push_notifications.should == types
      end
  end
end
