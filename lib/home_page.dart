import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:flight_local/apiService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int limit = 4;
  int skip = 0;
  int count;
  String token = '';

  ScrollController controller = ScrollController();

  APIService _apiService = APIService();

  @override
  initState() {
    super.initState();
    //controller listener for the swipe and load more option
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        print('get more data');
        if (count > skip + 4) {
          setState(() {
            skip = skip + 4;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // query for the grapQL to get the products
    var vrai = '''{
          getPackages(
              pagination: {skip: $skip limit: $limit
              })
            {statusCode
              message
              result {count packages {
              uid
              title
              startingPrice
              thumbnail
              amenities {
                title
                icon
              }
              discount {
                title
                amount
              }
              durationText
              loyaltyPointText
              description
                }
              }
            }
          }''';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        //appbar title
        child: AppBar(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Text(
                'FLIGHT',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                'LOCAL',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            // to sign in I made a static login system. anyone will sign in through this button to see the discount part.
            Query(
              options: QueryOptions(document: gql('''
                   mutation {
                      loginClient (
                       auth: {
                          email: "devteam@saimonglobal.com"
                          deviceUuid: "7026a238-d078-48b5-862b-c3c7d21d8712"
                        }
                        password: "12345678"
                      )
                     {
                       message
                       statusCode
                       result {
                         token
                         refreshToken
                         expiresAt
                       }
                     }
                    }
                    ''')),
              builder: (QueryResult result, {fetchMore, refetch}) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      if (token != '') {
                        setState(() {
                          token = '';
                        });
                      } else {
                        setState(() {
                          token = result.data['loginClient']['result']['token'];
                        });
                      }
                    },
                    child: Container(
                      height: 0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).primaryColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Center(
                            child: Text(
                          token == '' ? 'Sign In' : 'Sign Out',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          if (skip > 0) {
            setState(() {
              skip = skip - 4;
            });
          }
        },
        child: Container(
          child: token == ''
              ? Query(
                  options: QueryOptions(document: gql(vrai)),
                  builder: (QueryResult result, {fetchMore, refetch}) {
                    if (result.hasException) {
                      return Center(child: Text(result.exception.toString()));
                    }
                    if (result.isLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final packagesList = result.data['getPackages']['result'];
                    count = result.data['getPackages']['result']['count'];
                    return packages(
                      packagesList,
                      context,
                    );
                  })
              : FutureBuilder(
                  future: _apiService.getPackages(token, vrai),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return packages(
                          snapshot.data['data']['getPackages']['result'],
                          context);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
        ),
      ),
    );
  }

//this is the column that will show the entire list
  Column packages(
    packagesList,
    BuildContext context,
  ) {
    return Column(
      children: [
        //to show the available holidatys
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              Text(
                packagesList['count'].toString() + ' Available Holidays',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        packagesList['packages'].length == 0
            ? Center(
                child: Text('No more packages'),
              )
            : Container(),
        Expanded(
          //making the list scrollable and also scroll down functionality through this widget
          child: SingleChildScrollView(
            controller: controller,
            physics: ScrollPhysics(),
            child: Container(
              child: Scrollbar(
                //list of packages
                child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: packagesList['packages'].length,
                    itemBuilder: (context, index) {
                      //single tile of package
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 175,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: Offset(2, 2),
                                )
                              ]),
                          child:
                              //cards main column
                              Column(
                            children: [
                              //upper row
                              Expanded(
                                flex: 20,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Stack(children: [
                                        //thumbnail
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(5))),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(5)),
                                            child: Image.network(
                                              packagesList['packages'][index]
                                                  ['thumbnail'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        //best value tag
                                        packagesList['packages'][index]
                                                    ['discount'] ==
                                                null
                                            ? Container()
                                            : Container(
                                                width: 95,
                                                decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft: Radius
                                                                .circular(5),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    5))),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 9,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Text(
                                                        packagesList['packages']
                                                                    [index]
                                                                ['discount']
                                                            ['title'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ]),
                                    ),
                                    //details part
                                    Expanded(
                                      flex: 7,
                                      child: Container(
                                        height: 120,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              //title
                                              Text(
                                                packagesList['packages'][index]
                                                    ['title'],
                                                maxLines: 1,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                              ),
                                              SizedBox(height: 5),
                                              //description
                                              Text(
                                                packagesList['packages'][index]
                                                    ['description'],
                                                maxLines: 3,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 8),
                                              ),
                                              SizedBox(height: 7),
                                              //time duration
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons
                                                        .solidCalendar,
                                                    size: 11,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    packagesList['packages']
                                                        [index]['durationText'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              // flight local point
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.globe,
                                                    size: 11,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    packagesList['packages']
                                                            [index]
                                                        ['loyaltyPointText'],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              //bottom bar
                              Expanded(
                                flex: 9,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //includes icons (left part)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 5),
                                          child: Text(
                                            'Includes',
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context)
                                                    .hintColor),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, bottom: 10),
                                            //for icons list
                                            child: ListView.separated(
                                                separatorBuilder:
                                                    (context, index) {
                                                  return SizedBox(
                                                    width: 5,
                                                  );
                                                },
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    packagesList['packages']
                                                            [index]['amenities']
                                                        .length,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: SvgPicture.network(
                                                        packagesList['packages']
                                                                    [index]
                                                                ['amenities']
                                                            [index]['icon'],
                                                        color: Theme.of(context)
                                                            .hintColor,
                                                      ));
                                                }),
                                          ),
                                        )
                                      ],
                                    ),
                                    //starts from (right part)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Starts from',
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '৳',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                packagesList['packages'][index]
                                                        ['startingPrice']
                                                    .toString(),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
