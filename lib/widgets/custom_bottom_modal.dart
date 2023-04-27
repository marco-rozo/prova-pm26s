import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:prova_pm26s/model/turist_spots.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomBottomModal extends StatelessWidget {
  final TuristSpots turistSpots;

  final double distance;
  const CustomBottomModal({
    super.key,
    required this.turistSpots,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.keyboard_arrow_down_sharp),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${turistSpots.id} - ${turistSpots.name}',
              ),
              Text(
                '${turistSpots.dateFormatted}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Horario de funcionamento: ${turistSpots.workingHours}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Diferenciais: ${turistSpots.differential}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Latitude: ${turistSpots.latitude}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Longitude: ${turistSpots.longitude}',
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Distancia em km (linha reta): ${distance.toStringAsFixed(2).replaceAll('.', ',')} km',
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: turistSpots.urlPhoto ??
                    'http://via.placeholder.com/350x150',
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(Icons.error),
                ),
                fit: BoxFit.fill,
                width: _width * 0.8,
              ),
              // Image.network(
              //   turistSpots.urlPhoto ?? 'http://via.placeholder.com/350x150',
              //   fit: BoxFit.fill,
              //   width: _width * 0.8,
              // )
            ],
          )
        ],
      ),
    );
  }
}
