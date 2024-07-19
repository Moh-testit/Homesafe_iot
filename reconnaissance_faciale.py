import threading
import cv2
import dlib
import numpy as np
import json
import base64
from websocket_server import WebsocketServer

# Charger les images de référence avec les noms associés
reference_images = [
    ('Sidy', cv2.imread('known_face1.jpg')),
    ('Mohamed', cv2.imread('known_face2.jpg'))
]

# Convertir les images de référence en niveaux de gris et obtenir les points de repère
def get_landmarks(image_gray):
    rects = detector(image_gray, 0)
    if len(rects) > 0:
        rect = rects[0]
        shape = predictor(image_gray, rect)
        landmarks = np.array([[p.x, p.y] for p in shape.parts()])
        return landmarks
    else:
        raise Exception("No face detected in the reference image")

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")

landmarks_references = []
for name, image in reference_images:
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    landmarks = get_landmarks(gray)
    landmarks_references.append((name, landmarks))

vs = cv2.VideoCapture(0)

server = WebsocketServer('0.0.0.0', 8765)
print('Server listening on port 8765...')

def new_client(client, server):
    print(f"New client connected: {client['address']}")

def client_left(client, server):
    print(f"Client disconnected: {client['address']}")

def send_face_data():
    while True:
        ret, frame = vs.read()
        if not ret:
            break

        frame = cv2.resize(frame, (640, 480))
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        rects = detector(gray, 0)
        face_detected = False
        detected_name = ""
        if len(rects) > 0:
            rect = rects[0]
            shape = predictor(gray, rect)
            landmarks = np.array([[p.x, p.y] for p in shape.parts()])

            # Vérifier si les points de repère correspondent à l'une des images de référence
            tolerance = 50
            for name, landmarks_reference in landmarks_references:
                diff = np.linalg.norm(landmarks - landmarks_reference, axis=1)
                if np.all(diff < tolerance):
                    face_detected = True
                    detected_name = name
                    break

            if face_detected:
                cv2.putText(frame, detected_name, (rect.left(), rect.top() - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)

            frame_base64 = base64.b64encode(cv2.imencode('.jpg', frame)[1]).decode('utf-8')
            data = {
                'face_detected': face_detected,
                'frame': frame_base64,
                'landmarks': landmarks.tolist(),
                'name': detected_name
            }
        else:
            data = {
                'face_detected': False,
                'frame': '',
                'landmarks': [],
                'name': ""
            }

        server.send_message_to_all(json.dumps(data))
        cv2.imshow("Frame", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

server.set_fn_new_client(new_client)
server.set_fn_client_left(client_left)

send_face_data_thread = threading.Thread(target=send_face_data)
send_face_data_thread.start()

server.run_forever()
