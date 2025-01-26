import 'package:flutter/material.dart';
import 'package:muslim_mariage/screens/chat/video_call_page.dart';
import 'package:muslim_mariage/utils/colors.dart';
import 'package:muslim_mariage/widgets/save_button.dart';
import 'package:pay/pay.dart';
import 'payment_configuration.dart' as payment_configurations;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

const paymentItems = [
  PaymentItem(
    label: 'Total',
    amount: '10.00',
    status: PaymentItemStatus.final_price,
  ),
];

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/logo.png",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Kindly Pay The Fees To initiate \n Call in INR 1100",
              style: TextStyle(color: black, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            Center(
              child: GooglePayButton(
                paymentConfiguration:
                    payment_configurations.defaultGooglePayConfig,
                paymentItems: paymentItems,
                type: GooglePayButtonType.buy,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            // Example pay button configured using a string
            Center(
              child: ApplePayButton(
                paymentConfiguration:
                    payment_configurations.defaultApplePayConfig,
                paymentItems: paymentItems,
                style: ApplePayButtonStyle.black,
                type: ApplePayButtonType.buy,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: onApplePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Center(
            //     child: SaveButton(
            //         title: "Call",
            //         onTap: () {
            //           Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                   builder: (builder) => VideoCallPage()));
            //         }),
            //   ),
            // )
          ],
        ));
  }

  void onApplePayResult(paymentResult) {
    // Send the resulting Apple Pay token to your server / PSP
  }

  void onGooglePayResult(paymentResult) {
    // Send the resulting Google Pay token to your server / PSP
  }
}
