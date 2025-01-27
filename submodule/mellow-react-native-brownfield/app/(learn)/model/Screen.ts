export default interface Screen {
  id: number; // Screen number
  header: string; // Screen title/header
  image: string | null; // Path to the screen image (or null if no image)
  text: string | null; // Screen descriptive text (or null if no text)
}
