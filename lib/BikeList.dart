import 'package:flutter/material.dart';
import 'package:mybike/Controller/BikeListController.dart';
import 'package:mybike/model/bike_model.dart';

class BikeListWidget extends StatelessWidget {
  final BikeListController _controller = BikeListController();

  BikeListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          'จักรยานทั้งหมด',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[600],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<BikeModel>>(
        stream: _controller.getBikes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyStateWidget(context);
          }

          final bikes = snapshot.data!;
          return _buildBikeList(bikes);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            'เกิดข้อผิดพลาด',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.blue[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bike,
            color: Colors.blue[300],
            size: 100,
          ),
          const SizedBox(height: 16),
          Text(
            'ยังไม่มีจักรยาน',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBikeList(List<BikeModel> bikes) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: bikes.length,
      itemBuilder: (context, index) {
        final bike = bikes[index];
        return _buildBikeListItem(context, bike);
      },
    );
  }

  Widget _buildBikeListItem(BuildContext context, BikeModel bike) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.motorcycle,
            color: Colors.blue[600],
          ),
        ),
        title: Text(
          bike.bikeName,
          style: TextStyle(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'สถานะ: ${bike.status}',
          style: TextStyle(color: Colors.blue[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue[600],
        ),
        onTap: () {
          _controller.navigateToControlScreen(context, bike);
        },
      ),
    );
  }
}
