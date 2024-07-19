import cv2

def convert_to_rgb(image):
    """Convert an image to RGB format."""
    return cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

def capture_reference_images():
    cap = cv2.VideoCapture(0)
    face_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        cv2.imshow('Capture Your Face', frame)

        if cv2.waitKey(1) & 0xFF == ord('s'):  # Press 's' to save
            face_count += 1
            rgb_frame = convert_to_rgb(frame)
            filename = f'known_face{face_count}.jpg'
            cv2.imwrite(filename, rgb_frame)
            print(f"Face saved as '{filename}'")
            if face_count == 2:
                break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    capture_reference_images()
