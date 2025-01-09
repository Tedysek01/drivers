
import 'package:drivers/style/barvy.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 50,),
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Akce v okoli',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: colorScheme.onPrimary),
                      ),
                      Text(
                        'Zobrazit vse...',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: colorScheme.onPrimary),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, left: 10, right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Liberecka srazova sraz u globusu',
                                      style: TextStyle(
                                          fontFamily: 'Inter',
                                          color:colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          )),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined, size: 20,),
                                      SizedBox(width: 5,),
                                      Text('Globus Liberec, Liberec',style: TextStyle(
                                        color: colorScheme.onPrimary,

                                      ),)
                                    ],
                                  ),
                                  SizedBox(height: 2,),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range, size: 20,),
                                      SizedBox(width: 5,),
                                      Text('13.3.2025 18:30',style: TextStyle(
                                        color: colorScheme.onPrimary,)),
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 215, 147, 247),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.drive_eta_outlined,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(122, 28, 172,1),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, left: 10, right: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drifty Jablonec',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color:Color.fromRGBO(235, 211, 248,1),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined),
                                      Text('Jablonec nad Nisou')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range),
                                      Text('13.4.2025 20:00')
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 174, 213, 245),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.cloudy_snowing,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                     
                     SizedBox(height: 10,),
                     ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.add),
                          label: Text('Vytvorit akci'),
                          style: ElevatedButton.styleFrom(
                            
                            foregroundColor:Color.fromRGBO(235, 211, 248,1),
                            backgroundColor: Colors.blue,
                            iconColor: Colors.white,
                            iconSize: 20,
                            textStyle: TextStyle(fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10), // Set the radius here
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/servis.png'), opacity: 0.7, ),
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Servis',style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/fotogtaf.png'), opacity: 0.7),
                        color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Fotografování',style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    alignment: Alignment(-1, 1),
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/detailing.png'), opacity: 0.7),
                  color: const Color.fromARGB(255, 0, 0, 0),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: 115,
                    width: 115,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Detailing', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment(-1, 1),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/okresky.png'),fit: BoxFit.cover, opacity: 0.7),
                  color: const Color.fromARGB(255, 0, 0, 0),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: 115,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Okresky', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
              ),
            ),
            
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment(-1, 1),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/benzinky.png'), opacity: 0.7, fit: BoxFit.cover),
                      color: const Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: 115,
                  width: 245,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Ceny Benzínu a Nafty', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  ),
                ),
                Container(
                  alignment: Alignment(-1, 1),
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('assets/oko.png'), opacity: 0.7, ),
                      color: const Color.fromARGB(255, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: 115,
                  width: 115,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Dalsi...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  ),)
              ],
            )
          ],
        ),
      ),
    );
  }
}
