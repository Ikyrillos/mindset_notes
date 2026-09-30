import 'dart:developer';

abstract interface class PaymentMethod {
  Future<void> pay(double amount);
}

class VisaPayment implements PaymentMethod {
  @override
  Future<void> pay(double amount) async {
    log('Visa: $amount');
  }
}

class PaymobPayment implements PaymentMethod {
  @override
  Future<void> pay(double amount) async {
    log('PayMob: $amount');
  }
}

class Checkout {
   // i depended on concrete implmementation of payment method, which is not good

   // always depend on abstraction, not concrete implementation
  final PaymentMethod paymentMethod;

  Checkout(this.paymentMethod);

  Future<void> checkout(double amount) async {
    await paymentMethod.pay(amount);
  }
}


void main() async {
  final visa = VisaPayment();
  final paymob = PaymobPayment();
  
  final checkout = Checkout(paymob);

  await checkout.checkout(100);
}