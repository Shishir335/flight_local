import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  final HttpLink httpLink = HttpLink('https://b2c-api.flightlocal.com/graphql');
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(link: httpLink, cache: GraphQLCache(store: InMemoryStore())),
  );

  var app = GraphQLProvider(
    client: client,
    child: MyApp(),
  );
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flight Local',
      theme: ThemeData(
        primaryColor: Color(0xff00276c),
        hintColor: Color(0xffcfb350),
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int limit = 4;
  int skip = 0;
  @override
  Widget build(BuildContext context) {
    print(limit);
    print(skip);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
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
        ),
      ),
      body: Container(
        child: Query(
            options: QueryOptions(document: gql('''{
          getPackages(
            pagination: {
              skip: $skip
              limit: $limit
            }
          )
          {
            statusCode
            message
            result {
              count
              packages {
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
        }''')),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                return Center(child: Text(result.exception.toString()));
              }
              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }
              final packagesList = result.data?['getPackages']['result'];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          packagesList['count'].toString() +
                              ' Available Holidays',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Container(
                        child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10);
                            },
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: packagesList['packages'].length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    // crossAxisAlignment:
                                    //     CrossAxisAlignment.start,
                                    children: [
                                      //upper row
                                      Expanded(
                                        flex: 20,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                height: 120,
                                                // width: 150,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5))),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5)),
                                                  child: Image.network(
                                                    packagesList['packages']
                                                        [index]['thumbnail'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Container(
                                                height: 120,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      // vertical: 5,
                                                      horizontal: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        packagesList['packages']
                                                            [index]['title'],
                                                        style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                            // fontStyle: FontStyle.italic,
                                                            ),
                                                      ),
                                                      Text(
                                                        packagesList['packages']
                                                                [index]
                                                            ['description'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 8),
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .solidCalendar,
                                                            size: 11,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            packagesList[
                                                                        'packages']
                                                                    [index][
                                                                'durationText'],
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            FontAwesomeIcons
                                                                .globe,
                                                            size: 11,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            packagesList[
                                                                        'packages']
                                                                    [index][
                                                                'loyaltyPointText'],
                                                            style: GoogleFonts.poppins(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Theme.of(
                                                                        context)
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
                                      Expanded(
                                        flex: 9,
                                        child:  Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                               Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,top: 5),
                                                      child: Text(
                                                        'Includes',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Theme.of(
                                                                        context)
                                                                    .hintColor),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                                left: 10,bottom: 10),
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
                                                            itemCount: packagesList[
                                                                            'packages']
                                                                        [index]
                                                                    ['amenities']
                                                                .length,
                                                            itemBuilder:
                                                                (context, index) {
                                                              return Container(
                                                                  height: 12,
                                                                  width: 12,
                                                                  child: SvgPicture
                                                                      .network(
                                                                    packagesList['packages']
                                                                                [
                                                                                index]
                                                                            [
                                                                            'amenities']
                                                                        [
                                                                        index]['icon'],
                                                                    color: Theme.of(
                                                                            context)
                                                                        .hintColor,
                                                                  ));
                                                            }),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              
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
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text( '৳',
                                                          
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight.w700,
                                                              color: Colors.white),
                                                        ),
                                                        Text( 
                                                          packagesList['packages']
                                                                      [index]
                                                                  ['startingPrice']
                                                              .toString(),
                                                          style: GoogleFonts.poppins(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight.w700,
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
                ],
              );
            }),
      ),
    );
  }
}
