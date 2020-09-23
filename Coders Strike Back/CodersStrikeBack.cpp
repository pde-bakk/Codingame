#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <cmath>
#include <chrono>


// std::cout << "Time difference = " << std::chrono::duration_cast<std::chrono::nanoseconds> (endtime - begintime).count() << "[ns]" << std::endl;

using namespace std;

struct   Point {
    Point() : x(0), y(0) {}
    Point(float a, float b) : x(a), y(b) {}
    void   normalize() {float len = distance( Point(0, 0)); x /= len; y /= len; }
    Point& operator=(Point& rhs) { x = rhs.x; y = rhs.y; return *this; }
    Point& operator+(Point& rhs) { this->x += rhs.x; this->y += rhs.y; return *this; }
    Point& operator-(Point& rhs) { this->x = x - rhs.x; this->y -= rhs.y; return *this; }
    Point& operator/(float div) { this->x /= div; this->y /= div; return *this; }
    Point& operator*=(float mul) { this->x *= mul; this->y *= mul; return *this; }
    Point& operator-=(Point& rhs) { *this = *this - rhs; return *this; }
    float x, y;
    float distance2(Point p) { return (x - p.x)*(x - p.x) + (y - p.y)*(y - p.y); }
    float   distance(Point p) { return sqrt(distance2(p)); }
    Point   closest(Point a, Point b) { return (distance(a) < distance(b) ? a : b); }
    void    assign(float a, float b) { x = a; y = b; }
};
std::ostream&	operator<<(std::ostream& out, const Point& self) {
    out << "Point [" << self.x << ", " << self.y << "] ";
    return out;
}

class   Pod {
public:
         Pod() {}
         Pod(int i, int checkpoints, int laps) : id(i), checkpointCount(checkpoints), laps(laps), realcheckpoint() {}
    void instanciate() { cin >> pos.x >> pos.y >> v.x >> v.y >> angle >> nextCheckPointId; cin.ignore(); }
    void calcThrust(vector<int>, vector<int>);
    int  gethit();
    int  getThrust() { return this->thrust; }
    void setCheckPointCoords(vector<int> xcoords, vector<int> ycoords) {
        checkpoint.x = xcoords[nextCheckPointId];
        checkpoint.y = ycoords[nextCheckPointId];
        distance = pos.distance(checkpoint);
        pred = pos + v;
        cerr << id << " predicts to go to " << pred << endl;
        realcheckpoint = checkpoint;
        checkpoint -= v;
        cerr << id << " targets " << checkpoint << endl;
    }
    void take_action(int turn) {
        if (id == turn && distance > 2000)
            cout << floor(checkpoint.x) << " " << floor(checkpoint.y) << " " << "BOOST" << " distance: " << distance << ", speed = " << speed << "." << endl;
        else
            cout << floor(checkpoint.x) << " " << floor(checkpoint.y) << " " << thrust << " distance: " << distance << ", speed = " << speed << "." << endl;
    }
    float getAngle(Point p) {
        float d = pos.distance(p);
        float dx = (p.x - pos.x) / d;
        float dy = (p.y - pos.y) / d;

        // Simple trigonometry. We multiply by 180.0 / PI to convert radiants to degrees.
        float a = acos(dx) * 180.0 / M_PI;

        // If the point I want is below me, I have to shift the angle for it to be correct
        if (dy < 0) {
            a = 360.0 - a;
        }
        return a;
    }
    float diffAngle(Point p) {
        float a = this->getAngle(p);

        // To know whether we should turn clockwise or not we look at the two ways and keep the smallest
        // The ternary operators replace the use of a modulo operator which would be slower
        float right = this->angle <= a ? a - this->angle : 360.0 - this->angle + a;
        float left = this->angle >= a ? this->angle - a : this->angle + 360.0 - a;

        if (right < left) {
            return right;
        } else {
            // We return a negative angle if we must rotate to left
            return -left;
        }
    }
private:
    Point   pos,
            v,
            realcheckpoint,
            checkpoint,
            prev,
            pred;
    int     laps, id, checkpointCount, nextCheckPointId, angle, distance, thrust, speed;
};

int  Pod::gethit() {
    // float len = pos.distance(checkpoint);
    // cerr << "checkpoint: " << realcheckpoint << endl;
    Point closest = (pos - realcheckpoint);
    // cerr << "closest:" << closest << endl;
    closest.normalize();
    closest *= 600;
    closest = realcheckpoint + closest;
    // std::cerr << "checkpoint is at " << realcheckpoint << ", closest hitpoint is at " << closest << endl;
    return 0;
}

void Pod::calcThrust(vector<int> xcoords, vector<int> ycoords) {
    speed = sqrt( pow(v.x, 2) + pow(v.y, 2) );
    thrust = 100;
    float rotationOff = this->diffAngle(checkpoint);
    if (rotationOff > 18.0f) {
        rotationOff = 18.0f;
        thrust = 50;
        if (distance < 1500)
            thrust = 20;
        return ;
    }
    else if (rotationOff < -18.0f) {
        rotationOff = -18.0f;
        thrust = 50;
        if (distance < 1500)
            thrust = 20;
        return ;
    }
    gethit();
    cerr << "pod[" << id << "] has distance " << distance << " with speed " << speed << ", and rot " << rotationOff << endl;
    if (distance < 3000 && 6 * speed > distance) {
        int newCheckpoint = nextCheckPointId + 1;
        if (newCheckpoint >= checkpointCount)
            newCheckpoint = 0;
        checkpoint.assign(xcoords[newCheckpoint] + (xcoords[newCheckpoint] - pred.x), ycoords[newCheckpoint] + (ycoords[newCheckpoint] - pred.y));
        rotationOff = this->diffAngle(checkpoint);
        if (rotationOff > 60 || rotationOff < -60)
            thrust = 0;
        cerr << "pod[" << id << "] has a rotationOff of " << rotationOff << " to the NEXT cp" << endl;
    }
}

std::chrono::steady_clock::time_point begintime;
std::chrono::steady_clock::time_point endtime;
int main()
{
    int laps;
    int turn = 0;
    cin >> laps; cin.ignore();
    int checkpointCount;
    cin >> checkpointCount; cin.ignore();
    std::vector<int> checkpointsX;
    std::vector<int> checkpointsY;
    for (int i = 0; i < checkpointCount; i++) {
        int checkpointX;
        int checkpointY;
        cin >> checkpointX >> checkpointY; cin.ignore();
        checkpointsX.push_back(checkpointX);
        checkpointsY.push_back(checkpointY);
    }
    vector<Pod> myPods;
    vector<Pod> theirPods;

    while (1) {
        begintime = std::chrono::steady_clock::now();
        myPods.clear();
        theirPods.clear();
        for (int i = 0; i < 2; i++) {
            Pod tmp(i, checkpointCount, laps);
            tmp.instanciate();
            myPods.push_back(tmp);
        }
        for (int i = 0; i < 2; i++) {
            Pod tmp(i, checkpointCount, laps);
            tmp.instanciate();
            theirPods.push_back(tmp);
        }
        for (int i = 0; i < 2; i++) {
            myPods[i].setCheckPointCoords(checkpointsX, checkpointsY);
            // endtime = std::chrono::steady_clock::now();
            // std::cerr << "Time elapsed before calcthrust() = " << std::chrono::duration_cast<std::chrono::milliseconds>(endtime - begintime).count() << "[ms]" << std::endl;
            myPods[i].calcThrust(checkpointsX, checkpointsY);
            myPods[i].take_action(turn);
        }
        endtime = std::chrono::steady_clock::now();
        std::cerr << "Time elapsed in total! = " << std::chrono::duration_cast<std::chrono::milliseconds>(endtime - begintime).count() << "[ms]" << std::endl;
        ++turn;
    }
}
