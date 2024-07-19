# test_face_recognition.py

import unittest
from unittest.mock import patch, MagicMock
import cv2
import numpy as np

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

class TestFaceRecognition(unittest.TestCase):

    @patch('cv2.cvtColor')
    def test_convert_to_rgb(self, mock_cvtColor):
        # Arrange
        image = MagicMock()  # Mock image
        mock_cvtColor.return_value = 'rgb_image'
        
        # Act
        rgb_image = convert_to_rgb(image)
        
        # Assert
        mock_cvtColor.assert_called_with(image, cv2.COLOR_BGR2RGB)
        self.assertEqual(rgb_image, 'rgb_image')
        print("test_convert_to_rgb passed")

    @patch('cv2.VideoCapture')
    @patch('cv2.imshow')
    @patch('cv2.waitKey')
    @patch('cv2.imwrite')
    def test_capture_reference_images(self, mock_imwrite, mock_waitKey, mock_imshow, mock_VideoCapture):
        # Arrange
        mock_cap = MagicMock()
        mock_VideoCapture.return_value = mock_cap
        # Simulate two frames and then a stop
        mock_cap.read.side_effect = [
            (True, np.zeros((100, 100, 3), dtype=np.uint8)),  # Simulate a black image
            (True, np.zeros((100, 100, 3), dtype=np.uint8)),  # Another black image
            (False, None)  # End of video stream
        ]
        mock_waitKey.side_effect = [ord('s'), ord('s')]  # Simulate pressing 's' twice

        # Act
        capture_reference_images()

        # Assert
        self.assertEqual(mock_imwrite.call_count, 2, "Expected 2 images to be saved")
        # Convert np.array to list to compare with mocked calls
        args_list = [call[1] for call in mock_imwrite.call_args_list]
        saved_images = [np.zeros((100, 100, 3), dtype=np.uint8)] * 2
        
        for saved_image in saved_images:
            self.assertTrue(any(np.array_equal(arg, saved_image) for arg in args_list))
        
        mock_cap.release.assert_called_once()
        cv2.destroyAllWindows.assert_called_once()
        print("test_capture_reference_images passed")

if __name__ == '__main__':
    unittest.main()
