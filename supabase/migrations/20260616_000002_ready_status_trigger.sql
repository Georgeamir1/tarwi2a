-- Migration: Add support for 'ready' order status in notifications trigger
-- Fixes L-4: Customers were not notified when their orders transitioned to 'ready'.

CREATE OR REPLACE FUNCTION notify_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_title text;
  v_body text;
BEGIN
  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  CASE NEW.status
    WHEN 'confirmed' THEN
      v_title := 'تم تأكيد طلبك';
      v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' تم تأكيده وجاري التجهيز';
    WHEN 'preparing' THEN
      v_title := 'جاري تجهيز طلبك';
      v_body := 'المطبخ بيحضر طلبك رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'ready' THEN
      v_title := 'طلبك جاهز';
      IF NEW.order_type = 'pickup' THEN
        v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' جاهز للاستلام في المطعم';
      ELSE
        v_body := 'طلبك رقم #' || LEFT(NEW.id::text, 8) || ' جاهز وجاري تسليمه للدليفري';
      END IF;
    WHEN 'out_for_delivery' THEN
      v_title := 'طلبك في الطريق';
      v_body := 'الدليفري في طريقه ليك بطلب رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'delivered' THEN
      v_title := 'تم توصيل طلبك';
      v_body := 'نتمنى تكون استمتعت بطلبك رقم #' || LEFT(NEW.id::text, 8);
    WHEN 'cancelled' THEN
      v_title := 'تم إلغاء الطلب';
      v_body := 'تم إلغاء طلبك رقم #' || LEFT(NEW.id::text, 8);
    ELSE
      RETURN NEW;
  END CASE;

  INSERT INTO notifications (user_id, title_ar, body_ar, type, reference_type, reference_id)
  VALUES (
    NEW.customer_id,
    v_title,
    v_body,
    'order_' || NEW.status,
    'order',
    NEW.id::text
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
