#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <cmath>

using namespace std;

int getThrust(int angle, int distance, int MySpeed) {
    int thrust = 100;
    if ( abs(angle) >= 90) {
        cerr << "abs(angle) = " << abs(angle) << ", thrust = 0" << endl;
        return 0;
    }
    // if (distance < 100)
    //     thrust = distance;
    cerr << "distance = " << distance << ", MySpeed = " << MySpeed << endl;
    if (distance < 1000 && MySpeed > distance) {
        thrust = 0;
        cerr << "distance = " << distance << ", MySpeed = " << MySpeed << ", thrust = 0" << endl;

    }
    return thrust;
}

int main()
{
    int turn = 0;
    int boostcount = 0;
    int x, y;
    int nextCheckpointX, nextCheckpointY;
    int nextCheckpointDist, nextCheckpointAngle;
    int previousX, previousY;
    int predX, predY;
    int MySpeed;

    // game loop
    while (1) {
        if (turn > 0) {
            previousX = x;
            previousY = y;
        }
        cin >> x >> y >> nextCheckpointX >> nextCheckpointY >> nextCheckpointDist >> nextCheckpointAngle; cin.ignore();
        if (turn == 0) {
            previousX = x;
            previousY = y;
        }
        int opponentX, opponentY;
        int targetX, targetY;
        MySpeed = sqrt( pow(x - previousX, 2) + pow(y - previousY, 2) );
        cin >> opponentX >> opponentY; cin.ignore();
        int oppoTargetDist = sqrt( pow(opponentX - targetX, 2) + pow(opponentY - targetY, 2));
        predX = x + (x - previousX);
        predY = y +  (y - previousY);
        nextCheckpointX += (nextCheckpointX - predX);
        nextCheckpointY += (nextCheckpointY - predY);
        int thrust = getThrust(nextCheckpointAngle, nextCheckpointDist, MySpeed);
        cerr << "thrust: " << thrust << endl;
        cerr << "my pos: [" << x << ", " << y << "]" << endl;
        cerr << "target: [" << nextCheckpointX << ", " << nextCheckpointY << "]" << endl;
        cerr << "distance: " << nextCheckpointDist << ", angle: " << nextCheckpointAngle << endl;
        if (boostcount == 0 && abs(nextCheckpointAngle) < 20 && nextCheckpointDist > 5000) //&& nextCheckpointDist < oppoTargetDist )
            cout << nextCheckpointX << " " << nextCheckpointY << " " << "BOOST" << endl;
        else
            cout << nextCheckpointX << " " << nextCheckpointY << " " << thrust << endl;
        turn++;
    }
}
