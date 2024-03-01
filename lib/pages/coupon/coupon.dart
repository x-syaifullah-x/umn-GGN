import 'package:flutter/material.dart';
import 'package:global_net/data/user.dart';
import 'package:global_net/pages/coupon/coupon_create.dart';
import 'package:global_net/pages/coupon/coupon_s.dart';
import 'package:google_fonts/google_fonts.dart';

class CouponPage extends StatelessWidget {
  final User user;

  const CouponPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appbar(context),
        body: _body(context, user),
      ),
    );
  }

  Widget _body(BuildContext context, User user) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    final bool isLargeScreen = width > 550;
    return isLargeScreen
        ? Row(
            children: [
              SizedBox(
                width: width * .55,
                child: Coupons(
                  user: user,
                ),
              ),
              const VerticalDivider(
                width: 0,
              ),
              Flexible(
                child: CouponCreate(
                  user: user,
                  isAppBarEnable: false,
                ),
              ),
            ],
          )
        : Center(
            child: Coupons(
              user: user,
              onAddCoupon: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return CouponCreate(user: user);
                    },
                  ),
                );
              },
            ),
          );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      // automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(
          color: Theme.of(context).shadowColor,
          width: 1,
        ),
      ),
      title: Text(
        'Coupon',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
        ),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
